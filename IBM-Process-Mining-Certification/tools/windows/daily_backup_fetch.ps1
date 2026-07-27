. "C:\IBM_PM\windows\pm_daily_config.ps1"

$ErrorActionPreference = "Stop"

$LogDir = "C:\IBM_PM\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $LocalBackupDir | Out-Null

$RunStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LocalLog = Join-Path $LogDir "daily_backup_fetch_$RunStamp.log"

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Write-Host $line
    Add-Content -Path $LocalLog -Value $line
}

function Run-Remote {
    param([string]$Command)
    ssh -p $SshPort -i $SshKey "$SshUser@$ServerIp" $Command
}

Write-Log "=== Fetch IBM PM daily backup ==="
Write-Log "Server          : $ServerIp / $ServerHostName"
Write-Log "Remote log      : $RemoteBackupLog"
Write-Log "Local backup dir: $LocalBackupDir"
Write-Log "Local log       : $LocalLog"

if (!(Test-Path $SshKey)) {
    throw "SSH key not found: $SshKey"
}

$MaxWaitMinutes = 120
$SleepSeconds = 60
$MaxLoops = [int](($MaxWaitMinutes * 60) / $SleepSeconds)
$RemoteBackupPath = ""

for ($i = 1; $i -le $MaxLoops; $i++) {
    Write-Log "Check backup status $i/$MaxLoops"

    $line = Run-Remote "grep 'Backup completed:' $RemoteBackupLog 2>/dev/null | tail -1" 2>$null

    if ($line -match "Backup completed:\s+(.+\.tar\.gz)") {
        $RemoteBackupPath = $Matches[1].Trim()
        Write-Log "Backup completed: $RemoteBackupPath"
        break
    }

    $running = Run-Remote 'PID=$(cat /home/itzuser/pm_backup_run.pid 2>/dev/null || true); if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then echo RUNNING; else echo STOPPED; fi' 2>$null

    if ($running -eq "STOPPED") {
        Write-Log "Backup process is not running and completed line was not found. Showing last log lines."
        Run-Remote "tail -100 $RemoteBackupLog 2>/dev/null || true" 2>&1 | Tee-Object -FilePath $LocalLog -Append
        throw "Backup may have failed. Check remote log: $RemoteBackupLog"
    }

    Start-Sleep -Seconds $SleepSeconds
}

if ([string]::IsNullOrWhiteSpace($RemoteBackupPath)) {
    throw "Backup not completed within $MaxWaitMinutes minutes. Check remote log: $RemoteBackupLog"
}

$FileName = Split-Path $RemoteBackupPath -Leaf
$LocalPath = Join-Path $LocalBackupDir $FileName

if (Test-Path $LocalPath) {
    $localSize = (Get-Item $LocalPath).Length
    $remoteSize = Run-Remote "stat -c %s $RemoteBackupPath 2>/dev/null || echo 0" 2>$null
    if ([string]$localSize -eq [string]$remoteSize) {
        Write-Log "Local backup already exists with same size. Skipping download: $LocalPath"
        Write-Log "=== Done ==="
        exit 0
    }
}

Write-Log "Download $RemoteBackupPath to $LocalPath"
scp -P $SshPort -i $SshKey "$SshUser@${ServerIp}:$RemoteBackupPath" $LocalPath 2>&1 | Tee-Object -FilePath $LocalLog -Append
if ($LASTEXITCODE -ne 0) {
    throw "scp failed. ExitCode=$LASTEXITCODE"
}

if (!(Test-Path $LocalPath)) {
    throw "Download failed: $LocalPath"
}

Get-Item $LocalPath | Format-List FullName,Length,LastWriteTime | Out-String | Tee-Object -FilePath $LocalLog -Append
Write-Log "Downloaded: $LocalPath"
Write-Log "=== Done ==="
