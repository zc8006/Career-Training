@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM IBM Process Mining 2.0.3 one-click restore launcher for Windows
REM Run this from a local clone of the repo.
REM It converts the remote restore script to LF, uploads the backup bundle and scripts
REM to the NEW VM, starts restore in the VM background with nohup, polls the remote log,
REM then updates Windows hosts and tests the endpoint.
REM Do NOT store real passwords in this file or commit backup bundles to GitHub.

REM ===== Edit these values =====
set "NEW_IP=<NEW_VM_PUBLIC_IP>"
set "NEW_HOSTNAME=<NEW_VM_HOSTNAME>"
set "SSH_PORT=2223"
set "SSH_USER=itzuser"
set "SSH_KEY=C:\IBM_PM\pem_ibmcloudvsi_download.pem"
set "BACKUP_DIR=C:\IBM_PM\backups"
set "BACKUP_DIR_FALLBACK=C:\IBM_PM_Backups"
set "BACKUP_BUNDLE="
REM Poll every 30 seconds, up to 180 tries = about 90 minutes.
set "POLL_SECONDS=30"
set "MAX_POLLS=180"
REM ============================

set "SCRIPT_DIR=%~dp0"
set "REMOTE_RESTORE_SCRIPT=%SCRIPT_DIR%..\linux\pm_restore_remote.sh"
set "REMOTE_RESTORE_SCRIPT_LF=%TEMP%\pm_restore_remote_lf.sh"
set "REMOTE_RUNNER_SCRIPT=%TEMP%\pm_restore_runner_lf.sh"
set "REMOTE_BUNDLE=/home/%SSH_USER%/pm_restore_bundle.tar.gz"
set "REMOTE_SCRIPT=/home/%SSH_USER%/pm_restore_remote.sh"
set "REMOTE_RUNNER=/home/%SSH_USER%/pm_restore_runner.sh"
set "REMOTE_LOG=/home/%SSH_USER%/pm_restore_run.log"
set "REMOTE_PID=/home/%SSH_USER%/pm_restore_run.pid"

for /f "delims=" %%F in ('powershell -NoProfile -Command "$paths=@('%BACKUP_DIR%','%BACKUP_DIR_FALLBACK%'); Get-ChildItem -Path $paths -Filter 'pm_full_backup_*.tar.gz' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"') do (
    set "BACKUP_BUNDLE=%%F"
)

if "%BACKUP_BUNDLE%"=="" (
  echo ERROR: No backup bundle found in %BACKUP_DIR% or %BACKUP_DIR_FALLBACK%
  pause
  exit /b 1
)

if "%NEW_IP%"=="<NEW_VM_PUBLIC_IP>" (
  echo ERROR: Please edit NEW_IP in this file first.
  pause
  exit /b 1
)

if "%NEW_HOSTNAME%"=="<NEW_VM_HOSTNAME>" (
  echo ERROR: Please edit NEW_HOSTNAME in this file first.
  pause
  exit /b 1
)

if not exist "%SSH_KEY%" (
  echo ERROR: SSH key not found: %SSH_KEY%
  pause
  exit /b 1
)

if not exist "%BACKUP_BUNDLE%" (
  echo ERROR: Backup bundle not found: %BACKUP_BUNDLE%
  pause
  exit /b 1
)

if not exist "%REMOTE_RESTORE_SCRIPT%" (
  echo ERROR: Remote restore script not found: %REMOTE_RESTORE_SCRIPT%
  pause
  exit /b 1
)

for %%A in ("%BACKUP_BUNDLE%") do (
  set "LOCAL_BUNDLE_SIZE=%%~zA"
  set "LOCAL_BUNDLE_NAME=%%~nxA"
)

echo === IBM Process Mining one-click restore ^(background mode^) ===
echo NEW_IP       : %NEW_IP%
echo NEW_HOSTNAME : %NEW_HOSTNAME%
echo SSH_PORT     : %SSH_PORT%
echo SSH_USER     : %SSH_USER%
echo BACKUP_BUNDLE: %BACKUP_BUNDLE%
echo BUNDLE_SIZE  : %LOCAL_BUNDLE_SIZE% bytes
echo REMOTE_LOG   : %REMOTE_LOG%
echo.

for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$p=Read-Host 'Enter PostgreSQL processmining DB plain password' -AsSecureString; $b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); try { [Runtime.InteropServices.Marshal]::PtrToStringAuto($b) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }"`) do set "DB_PASS=%%P"

if "%DB_PASS%"=="" (
  echo ERROR: DB password is empty.
  pause
  exit /b 1
)

if not "x%DB_PASS:'=%"=="x%DB_PASS%" (
  echo ERROR: DB password contains a single quote. Please change it first, then rerun restore.
  pause
  exit /b 1
)

for /f "usebackq delims=" %%B in (`powershell -NoProfile -Command "[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($env:DB_PASS))"`) do set "DB_PASS_B64=%%B"

if "%DB_PASS_B64%"=="" (
  echo ERROR: Failed to encode DB password.
  pause
  exit /b 1
)

echo.
echo [0/7] Convert remote restore script to LF line endings
powershell -NoProfile -ExecutionPolicy Bypass -Command "$src='%REMOTE_RESTORE_SCRIPT%'; $dst='%REMOTE_RESTORE_SCRIPT_LF%'; $txt=[System.IO.File]::ReadAllText($src); $txt=$txt.Replace([string][char]13 + [string][char]10, [string][char]10); [System.IO.File]::WriteAllText($dst, $txt, [System.Text.UTF8Encoding]::new($false))"
if errorlevel 1 goto :error

echo [1/7] Create remote nohup restore runner
(
  echo #!/bin/bash
  echo set -euo pipefail
  echo REMOTE_LOG="%REMOTE_LOG%"
  echo REMOTE_PID="%REMOTE_PID%"
  echo REMOTE_SCRIPT="%REMOTE_SCRIPT%"
  echo REMOTE_BUNDLE="%REMOTE_BUNDLE%"
  echo NEW_IP="%NEW_IP%"
  echo NEW_HOSTNAME="%NEW_HOSTNAME%"
  echo DB_PASS="$(printf '%%s' '%DB_PASS_B64%' ^| base64 -d)"
  echo rm -f "$REMOTE_LOG" "$REMOTE_PID"
  echo chmod +x "$REMOTE_SCRIPT"
  echo nohup bash "$REMOTE_SCRIPT" "$REMOTE_BUNDLE" "$NEW_IP" "$NEW_HOSTNAME" "$DB_PASS" ^> "$REMOTE_LOG" 2^>^&1 ^< /dev/null ^&
  echo echo $! ^> "$REMOTE_PID"
  echo echo "Restore started in background. PID=$(cat "$REMOTE_PID")"
  echo rm -f "$0"
) > "%REMOTE_RUNNER_SCRIPT%"
if errorlevel 1 goto :error

powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='%REMOTE_RUNNER_SCRIPT%'; $txt=[System.IO.File]::ReadAllText($p); $txt=$txt.Replace([string][char]13 + [string][char]10, [string][char]10); [System.IO.File]::WriteAllText($p, $txt, [System.Text.UTF8Encoding]::new($false))"
if errorlevel 1 goto :error

echo [2/7] Check or upload backup bundle to NEW VM
set "REMOTE_BUNDLE_SIZE="
for /f "usebackq delims=" %%S in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "if [ -f %REMOTE_BUNDLE% ]; then stat -c %%s %REMOTE_BUNDLE%; fi"`) do set "REMOTE_BUNDLE_SIZE=%%S"

if "%REMOTE_BUNDLE_SIZE%"=="%LOCAL_BUNDLE_SIZE%" (
  echo Remote bundle already exists with same size. Skipping upload.
  echo Remote bundle: %REMOTE_BUNDLE%
) else (
  if not "%REMOTE_BUNDLE_SIZE%"=="" (
    echo Remote bundle exists but size is different. Re-uploading.
    echo Remote size: %REMOTE_BUNDLE_SIZE% bytes
    echo Local size : %LOCAL_BUNDLE_SIZE% bytes
  ) else (
    echo Remote bundle not found. Uploading.
  )
  scp -P %SSH_PORT% -i "%SSH_KEY%" "%BACKUP_BUNDLE%" %SSH_USER%@%NEW_IP%:%REMOTE_BUNDLE%
  if errorlevel 1 goto :error
)

echo [3/7] Upload remote restore script and runner to NEW VM
scp -P %SSH_PORT% -i "%SSH_KEY%" "%REMOTE_RESTORE_SCRIPT_LF%" %SSH_USER%@%NEW_IP%:%REMOTE_SCRIPT%
if errorlevel 1 goto :error
scp -P %SSH_PORT% -i "%SSH_KEY%" "%REMOTE_RUNNER_SCRIPT%" %SSH_USER%@%NEW_IP%:%REMOTE_RUNNER%
if errorlevel 1 goto :error

echo [4/7] Start remote restore in VM background
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "chmod +x %REMOTE_RUNNER% && bash %REMOTE_RUNNER%"
if errorlevel 1 goto :error

echo Restore started. Polling remote log. This may take a while...
echo.

set /a POLL_COUNT=0

:poll_loop
set /a POLL_COUNT+=1
echo [5/7] Poll %POLL_COUNT%/%MAX_POLLS% - last log lines
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "tail -30 %REMOTE_LOG% 2>/dev/null || true"

set "RESTORE_DONE="
for /f "usebackq delims=" %%S in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "grep -q '=== Restore completed ===' %REMOTE_LOG% 2>/dev/null && echo DONE || true"`) do set "RESTORE_DONE=%%S"
if "%RESTORE_DONE%"=="DONE" goto :restore_done

set "RESTORE_FAILED="
for /f "usebackq delims=" %%S in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "grep -Eiq '(^ERROR:|FATAL:|pg_restore: error|tar: .*Error|No space left on device)' %REMOTE_LOG% 2>/dev/null && echo FAILED || true"`) do set "RESTORE_FAILED=%%S"
if "%RESTORE_FAILED%"=="FAILED" goto :restore_failed

set "RESTORE_RUNNING="
for /f "usebackq delims=" %%S in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "PID=\$(cat %REMOTE_PID% 2>/dev/null || true); if [ -n \"\$PID\" ] && kill -0 \"\$PID\" 2>/dev/null; then echo RUNNING; else echo STOPPED; fi"`) do set "RESTORE_RUNNING=%%S"
if "%RESTORE_RUNNING%"=="STOPPED" goto :restore_stopped

if %POLL_COUNT% GEQ %MAX_POLLS% goto :timeout

echo Waiting %POLL_SECONDS% seconds...
ping -n %POLL_SECONDS% 127.0.0.1 >nul
goto :poll_loop

:restore_done
echo.
echo [6/7] Update Windows hosts if this BAT is running as Administrator
net session >nul 2>&1
if errorlevel 1 (
  echo WARN: Not running as Administrator. Please update Windows hosts manually:
  echo %NEW_IP% pm.processmining tm.processmining %NEW_HOSTNAME%
) else (
  powershell -NoProfile -Command "$hosts='C:\Windows\System32\drivers\etc\hosts'; $lines=Get-Content $hosts | Where-Object {$_ -notmatch 'pm\.processmining' -and $_ -notmatch 'tm\.processmining'}; $lines + '%NEW_IP% pm.processmining tm.processmining %NEW_HOSTNAME%' | Set-Content $hosts -Encoding ascii"
  echo Windows hosts updated.
)

echo [7/7] Test PM endpoint from Windows
powershell -NoProfile -Command "Test-NetConnection pm.processmining -Port 443"
curl.exe -k -I https://pm.processmining

echo.
echo Restore completed.
echo Open      : https://pm.processmining/signin
echo Remote log: %REMOTE_LOG%
echo.
pause
exit /b 0

:restore_failed
echo.
echo ERROR: Remote restore log contains a failure marker.
echo Showing last 100 log lines:
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "tail -100 %REMOTE_LOG% 2>/dev/null || true"
goto :error

:restore_stopped
echo.
echo ERROR: Remote restore process stopped without success marker.
echo Showing last 100 log lines:
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "tail -100 %REMOTE_LOG% 2>/dev/null || true"
goto :error

:timeout
echo.
echo ERROR: Restore polling timed out after %MAX_POLLS% checks.
echo The remote restore may still be running. Check with:
echo ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "tail -100 %REMOTE_LOG%"
goto :error

:error
echo.
echo Restore failed. Check the error above.
echo Common checks:
echo - Is the SSH key correct?
echo - Is NEW_IP correct?
echo - Is the backup bundle path correct?
echo - Does the DB password contain a single quote? If yes, change it first.
pause
exit /b 1
