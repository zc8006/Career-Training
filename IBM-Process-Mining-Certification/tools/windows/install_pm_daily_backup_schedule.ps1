param(
    [Parameter(Mandatory = $true)]
    [string]$ServerIp,

    [string]$ServerHostName = "",

    [int]$SshPort = 2223,

    [string]$SshUser = "itzuser",

    [string]$SshKey = "C:\IBM_PM\pem_ibmcloudvsi_download.pem",

    [string]$LocalBackupScript = "C:\IBM_PM\linux\pm_backup_full.sh",

    [string]$LocalBackupDir = "C:\IBM_PM\backups",

    [string]$ConfigPath = "C:\IBM_PM\windows\pm_daily_config.ps1",

    [string]$FetchScript = "C:\IBM_PM\windows\daily_backup_fetch.ps1",

    # Beijing time by default. TechZone RHEL VMs normally use UTC, so 16:30 Beijing = 08:30 UTC.
    [int]$BackupHourBeijing = 16,

    [int]$BackupMinute = 30,

    # Windows local time for downloading the completed bundle.
    [string]$FetchTime = "17:00"
)

$ErrorActionPreference = "Stop"

$RemoteDir = "/home/$SshUser/pm_daily_backup"
$RemoteScript = "$RemoteDir/pm_backup_full.sh"
$RemoteCronLog = "$RemoteDir/pm_backup_cron.log"
$RemoteRunLog = "/home/$SshUser/pm_backup_run.log"
$RemotePid = "/home/$SshUser/pm_backup_run.pid"

$LogDir = "C:\IBM_PM\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $LocalBackupDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $ConfigPath -Parent) | Out-Null

$RunStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LocalLog = Join-Path $LogDir "install_pm_daily_backup_schedule_$RunStamp.log"

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Write-Host $line
    Add-Content -Path $LocalLog -Value $line
}

function Run-Command {
    param(
        [string]$Title,
        [scriptblock]$Command
    )
    Write-Log $Title
    & $Command 2>&1 | Tee-Object -FilePath $LocalLog -Append
    if ($LASTEXITCODE -ne 0) {
        throw "$Title failed. ExitCode=$LASTEXITCODE"
    }
}

if (!(Test-Path $SshKey)) {
    throw "SSH key not found: $SshKey"
}

if (!(Test-Path $LocalBackupScript)) {
    throw "Local backup script not found: $LocalBackupScript"
}

if (!(Test-Path $FetchScript)) {
    throw "Fetch script not found: $FetchScript. Please run git pull first."
}

if ([string]::IsNullOrWhiteSpace($ServerHostName)) {
    Write-Log "ServerHostName is empty. It is okay for cron, but Windows hosts still needs the real hostname when you update it."
}

$UtcHour = ($BackupHourBeijing - 8) % 24
if ($UtcHour -lt 0) { $UtcHour += 24 }
$CronLine = "$BackupMinute $UtcHour * * * /bin/bash $RemoteScript > $RemoteCronLog 2>&1"

Write-Log "=== Install IBM PM daily backup schedule ==="
Write-Log "Server             : $ServerIp / $ServerHostName"
Write-Log "Backup schedule    : Beijing $($BackupHourBeijing.ToString('00')):$($BackupMinute.ToString('00')) / UTC $($UtcHour.ToString('00')):$($BackupMinute.ToString('00'))"
Write-Log "Windows fetch time : $FetchTime"
Write-Log "Remote script      : $RemoteScript"
Write-Log "Remote cron log    : $RemoteCronLog"
Write-Log "Remote run log     : $RemoteRunLog"
Write-Log "Local backup dir   : $LocalBackupDir"
Write-Log "Config path        : $ConfigPath"
Write-Log "Local log          : $LocalLog"

$TempBackupScript = Join-Path $env:TEMP "pm_backup_full_lf.sh"
$txt = [System.IO.File]::ReadAllText($LocalBackupScript)
$txt = $txt.Replace("`r`n", "`n")
[System.IO.File]::WriteAllText($TempBackupScript, $txt, [System.Text.UTF8Encoding]::new($false))

Run-Command "Create remote backup folder" {
    ssh -p $SshPort -i $SshKey "$SshUser@$ServerIp" "mkdir -p $RemoteDir"
}

Run-Command "Upload LF backup script" {
    scp -P $SshPort -i $SshKey $TempBackupScript "$SshUser@${ServerIp}:$RemoteScript"
}

$RemoteInstallCronCommand = "sed -i 's/\r`$//' $RemoteScript && chmod +x $RemoteScript && (crontab -l 2>/dev/null | grep -v 'pm_daily_backup/pm_backup_full.sh'; echo '$CronLine') | crontab -"

Run-Command "Install server cron job" {
    ssh -p $SshPort -i $SshKey "$SshUser@$ServerIp" $RemoteInstallCronCommand
}

Run-Command "Show current server crontab" {
    ssh -p $SshPort -i $SshKey "$SshUser@$ServerIp" "crontab -l"
}

$config = @'
$ServerIp = "__SERVER_IP__"
$ServerHostName = "__SERVER_HOSTNAME__"
$SshPort = __SSH_PORT__
$SshUser = "__SSH_USER__"
$SshKey = "__SSH_KEY__"
$LocalBackupDir = "__LOCAL_BACKUP_DIR__"
$RemoteBackupLog = "__REMOTE_BACKUP_LOG__"
$RemoteBackupPid = "__REMOTE_BACKUP_PID__"
'@

$config = $config.Replace("__SERVER_IP__", $ServerIp)
$config = $config.Replace("__SERVER_HOSTNAME__", $ServerHostName)
$config = $config.Replace("__SSH_PORT__", [string]$SshPort)
$config = $config.Replace("__SSH_USER__", $SshUser)
$config = $config.Replace("__SSH_KEY__", $SshKey)
$config = $config.Replace("__LOCAL_BACKUP_DIR__", $LocalBackupDir)
$config = $config.Replace("__REMOTE_BACKUP_LOG__", $RemoteRunLog)
$config = $config.Replace("__REMOTE_BACKUP_PID__", $RemotePid)

[System.IO.File]::WriteAllText($ConfigPath, $config, [System.Text.UTF8Encoding]::new($false))
Write-Log "Updated local config: $ConfigPath"

$TaskName = "IBM PM Daily Backup Fetch"
$TaskCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$FetchScript`""
Run-Command "Create or update Windows scheduled task: $TaskName at $FetchTime" {
    schtasks /Create /TN $TaskName /SC DAILY /ST $FetchTime /TR $TaskCommand /F
}

Write-Log "=== Done ==="
Write-Host ""
Write-Host "Installed server cron: $CronLine"
Write-Host "Installed Windows task: $TaskName at $FetchTime"
Write-Host "Config file: $ConfigPath"
Write-Host "Next check: schtasks /Query /TN `"$TaskName`""
