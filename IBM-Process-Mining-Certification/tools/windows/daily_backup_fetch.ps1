. "C:\IBM_PM\windows\pm_daily_config.ps1"

$ErrorActionPreference = "Stop"

$LogDir = "C:\IBM_PM\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $LocalBackupDir | Out-Null

$RunStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LocalLog = Join-Path $LogDir "daily_backup_fetch_$RunStamp.log"

# Server-side backup can be started in two ways:
# 1) Windows-triggered background backup: /home/itzuser/pm_backup_run.log
# 2) Server cron backup: /home/itzuser/pm_daily_backup/pm_backup_cron.log
# Check both so the 17:00 Windows download task works after either workflow.
$RemoteBackupLogs = @(
    "/home/itzuser/pm_daily_backup/pm_backup_cron.log",
    "/home/itzuser/pm_backup_run.log"
)
$RemoteBackupPids = @(
    "/home/itzuser/pm_daily_backup/pm_backup_cron.pid",
    "/home/itzuser/pm_backup_run.pid"
)

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

function Escape-SingleQuoteForBash {
    param([string]$Value)
    return $Value.Replace("'", "'\''")
}

Write-Log "=== Fetch IBM PM daily backup ==="
Write-Log "Server          : $ServerIp / $ServerHostName"
Write-Log "Remote logs     : $($RemoteBackupLogs -join ', ')"
Write-Log "Local backup dir: $LocalBackupDir"
Write-Log "Local log       : $LocalLog"

if (!(Test-Path $SshKey)) {
    throw "SSH key not found: $SshKey"
}

$MaxWaitMinutes = 120
$SleepSeconds = 60
$MaxLoops = [int](($MaxWaitMinutes * 60) / $SleepSeconds)
$RemoteBackupPath = ""
$MatchedRemoteLog = ""

for ($i = 1; $i -le $MaxLoops; $i++) {
    Write-Log "Check backup status $i/$MaxLoops"

    foreach ($logPath in $RemoteBackupLogs) {
        $safeLogPath = Escape-SingleQuoteForBash $logPath
        $line = Run-Remote "grep 'Backup completed:' '$safeLogPath' 2>/dev/null | tail -1" 2>$null

        if ($line -match "Backup completed:\s+(.+\.tar\.gz)") {
            $RemoteBackupPath = $Matches[1].Trim()
            $MatchedRemoteLog = $logPath
            Write-Log "Backup completed according to ${MatchedRemoteLog}: $RemoteBackupPath"
            break
        }
    }

    if (![string]::IsNullOrWhiteSpace($RemoteBackupPath)) {
        break
    }

    # Cron-launched backups do not have a reliable PID file, so also detect running backup/tar/pg_dump processes.
    $running = Run-Remote "if pgrep -f 'pm_backup_full.sh|tar -czf|pg_dump' >/dev/null 2>&1; then echo RUNNING; else echo STOPPED; fi" 2>$null

    if ($running -eq "STOPPED") {
        # As a fallback, choose the newest finished-looking bundle created today or recently.
        $latestBundle = Run-Remote "ls -1t /home/itzuser/pm_full_backup_*.tar.gz 2>/dev/null | head -1" 2>$null
        if ($latestBundle -match "^/home/.+\.tar\.gz$") {
            $RemoteBackupPath = $latestBundle.Trim()
            Write-Log "No completion marker found, but found latest bundle: $RemoteBackupPath"
            break
        }

        Write-Log "Backup process is not running and completed line was not found. Showing last log lines."
        foreach ($logPath in $RemoteBackupLogs) {
            $safeLogPath = Escape-SingleQuoteForBash $logPath
            Write-Log "--- $logPath ---"
            Run-Remote "tail -100 '$safeLogPath' 2>/dev/null || echo NO_LOG" 2>&1 | Tee-Object -FilePath $LocalLog -Append
        }
        throw "Backup may have failed. Check remote logs: $($RemoteBackupLogs -join ', ')"
    }

    Start-Sleep -Seconds $SleepSeconds
}

if ([string]::IsNullOrWhiteSpace($RemoteBackupPath)) {
    throw "Backup not completed within $MaxWaitMinutes minutes. Check remote logs: $($RemoteBackupLogs -join ', ')"
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
