@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM IBM Process Mining 2.0.3 one-click backup launcher for Windows
REM Run this from a local clone of the repo.
REM It converts the Linux script to LF, uploads it to the OLD/CURRENT VM,
REM starts the backup in the VM background with nohup, polls the remote log,
REM then downloads the generated full backup bundle.
REM Do NOT commit generated backup bundles, certificates, keys, or dumps to GitHub.

REM ===== Edit these values =====
set "OLD_IP=<OLD_VM_PUBLIC_IP>"
set "SSH_PORT=2223"
set "SSH_USER=itzuser"
set "SSH_KEY=C:\IBM_PM\pem_ibmcloudvsi_download.pem"
set "LOCAL_BACKUP_DIR=C:\IBM_PM\backups"
REM Poll every 30 seconds, up to 120 tries = about 60 minutes.
set "POLL_SECONDS=30"
set "MAX_POLLS=120"
REM ============================

set "SCRIPT_DIR=%~dp0"
set "LINUX_BACKUP_SCRIPT=%SCRIPT_DIR%..\linux\pm_backup_full.sh"
set "LINUX_BACKUP_SCRIPT_LF=%TEMP%\pm_backup_full_lf.sh"
set "REMOTE_SCRIPT=/home/%SSH_USER%/pm_backup_full.sh"
set "REMOTE_LOG=/home/%SSH_USER%/pm_backup_run.log"
set "REMOTE_PID=/home/%SSH_USER%/pm_backup_run.pid"

if "%OLD_IP%"=="<OLD_VM_PUBLIC_IP>" (
  echo ERROR: Please edit OLD_IP in this file first.
  pause
  exit /b 1
)

if not exist "%SSH_KEY%" (
  echo ERROR: SSH key not found: %SSH_KEY%
  pause
  exit /b 1
)

if not exist "%LINUX_BACKUP_SCRIPT%" (
  echo ERROR: Linux backup script not found: %LINUX_BACKUP_SCRIPT%
  pause
  exit /b 1
)

if not exist "%LOCAL_BACKUP_DIR%" mkdir "%LOCAL_BACKUP_DIR%"

echo === IBM Process Mining one-click backup ^(background mode^) ===
echo OLD_IP          : %OLD_IP%
echo SSH_PORT        : %SSH_PORT%
echo SSH_USER        : %SSH_USER%
echo LOCAL_BACKUP_DIR: %LOCAL_BACKUP_DIR%
echo REMOTE_LOG      : %REMOTE_LOG%
echo.

echo [0/6] Convert Linux script to LF line endings
powershell -NoProfile -ExecutionPolicy Bypass -Command "$src='%LINUX_BACKUP_SCRIPT%'; $dst='%LINUX_BACKUP_SCRIPT_LF%'; $txt=[System.IO.File]::ReadAllText($src); $txt=$txt.Replace([string][char]13 + [string][char]10, [string][char]10); [System.IO.File]::WriteAllText($dst, $txt, [System.Text.UTF8Encoding]::new($false))"
if errorlevel 1 goto :error

echo [1/6] Upload backup script to OLD/CURRENT VM
scp -P %SSH_PORT% -i "%SSH_KEY%" "%LINUX_BACKUP_SCRIPT_LF%" %SSH_USER%@%OLD_IP%:%REMOTE_SCRIPT%
if errorlevel 1 goto :error

echo [2/6] Start backup in VM background
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "chmod +x %REMOTE_SCRIPT% && rm -f %REMOTE_LOG% %REMOTE_PID% && nohup bash %REMOTE_SCRIPT% > %REMOTE_LOG% 2>&1 < /dev/null & echo $! > %REMOTE_PID%"
if errorlevel 1 goto :error

echo Backup started. Polling remote log. This may take a while...
echo.

set /a POLL_COUNT=0

:poll_loop
set /a POLL_COUNT+=1
echo [3/6] Poll %POLL_COUNT%/%MAX_POLLS% - last log lines
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "tail -20 %REMOTE_LOG% 2>/dev/null || true"

set "BACKUP_DONE="
for /f "usebackq delims=" %%S in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "grep -q 'Backup completed:' %REMOTE_LOG% 2>/dev/null && echo DONE || true"`) do set "BACKUP_DONE=%%S"
if "%BACKUP_DONE%"=="DONE" goto :backup_done

set "BACKUP_FAILED="
for /f "usebackq delims=" %%S in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "grep -q 'ERROR: backup failed' %REMOTE_LOG% 2>/dev/null && echo FAILED || true"`) do set "BACKUP_FAILED=%%S"
if "%BACKUP_FAILED%"=="FAILED" goto :backup_failed

set "BACKUP_RUNNING="
for /f "usebackq delims=" %%S in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "PID=\$(cat %REMOTE_PID% 2>/dev/null || true); if [ -n \"\$PID\" ] && kill -0 \"\$PID\" 2>/dev/null; then echo RUNNING; else echo STOPPED; fi"`) do set "BACKUP_RUNNING=%%S"
if "%BACKUP_RUNNING%"=="STOPPED" goto :backup_stopped

if %POLL_COUNT% GEQ %MAX_POLLS% goto :timeout

echo Waiting %POLL_SECONDS% seconds...
ping -n %POLL_SECONDS% 127.0.0.1 >nul
goto :poll_loop

:backup_done
echo.
echo [4/6] Backup completed on VM. Find latest backup bundle
set "REMOTE_BUNDLE="
for /f "usebackq delims=" %%F in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "ls -1t /home/%SSH_USER%/pm_full_backup_*.tar.gz /home/%SSH_USER%/pm_backup_*.tar.gz 2>/dev/null | head -1"`) do set "REMOTE_BUNDLE=%%F"

if "%REMOTE_BUNDLE%"=="" (
  echo ERROR: Could not find remote backup bundle after successful log marker.
  goto :error
)

echo Latest remote bundle: %REMOTE_BUNDLE%

echo [5/6] Download backup bundle to local folder
scp -P %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP%:%REMOTE_BUNDLE% "%LOCAL_BACKUP_DIR%\"
if errorlevel 1 goto :error

for %%A in ("%REMOTE_BUNDLE%") do set "BUNDLE_NAME=%%~nxA"
set "LOCAL_BUNDLE=%LOCAL_BACKUP_DIR%\%BUNDLE_NAME%"

echo [6/6] Verify PM endpoint after backup
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "curl -k -I https://pm.processmining || true"

echo.
echo Backup completed successfully.
echo Local folder : %LOCAL_BACKUP_DIR%
echo Local bundle : %LOCAL_BUNDLE%
echo Remote log   : %REMOTE_LOG%
echo.
pause
exit /b 0

:backup_failed
echo.
echo ERROR: Remote backup script reported failure.
echo Showing last 80 log lines:
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "tail -80 %REMOTE_LOG% 2>/dev/null || true"
goto :error

:backup_stopped
echo.
echo ERROR: Remote backup process stopped without success marker.
echo Showing last 80 log lines:
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "tail -80 %REMOTE_LOG% 2>/dev/null || true"
goto :error

:timeout
echo.
echo ERROR: Backup polling timed out after %MAX_POLLS% checks.
echo The remote backup may still be running. Check with:
echo ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "tail -80 %REMOTE_LOG%"
goto :error

:error
echo.
echo Backup failed. Check the error above.
pause
exit /b 1
