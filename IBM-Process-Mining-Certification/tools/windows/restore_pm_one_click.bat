@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM IBM Process Mining 2.0.3 one-click restore launcher for Windows
REM Run this from a local clone of the repo.
REM It uploads the backup bundle and remote restore script to the NEW VM, then executes restore.
REM Do NOT store real passwords in this file or commit backup bundles to GitHub.

REM ===== Edit these values =====
set "NEW_IP=<NEW_VM_PUBLIC_IP>"
set "NEW_HOSTNAME=<NEW_VM_HOSTNAME>"
set "SSH_PORT=2223"
set "SSH_USER=itzuser"
set "SSH_KEY=C:\IBM_PM\pem_ibmcloudvsi_download.pem"
set "BACKUP_BUNDLE=C:\IBM_PM_Backups\pm_backup_YYYYMMDD_HHMMSS.tar.gz"
REM ============================

set "SCRIPT_DIR=%~dp0"
set "REMOTE_RESTORE_SCRIPT=%SCRIPT_DIR%..\linux\pm_restore_remote.sh"

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

echo === IBM Process Mining one-click restore ===
echo NEW_IP       : %NEW_IP%
echo NEW_HOSTNAME : %NEW_HOSTNAME%
echo SSH_PORT     : %SSH_PORT%
echo SSH_USER     : %SSH_USER%
echo BACKUP_BUNDLE: %BACKUP_BUNDLE%
echo.

REM Read DB password without echoing it to the console.
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$p=Read-Host 'Enter PostgreSQL processmining DB plain password' -AsSecureString; $b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [Runtime.InteropServices.Marshal]::PtrToStringAuto($b)"`) do set "DB_PASS=%%P"

if "%DB_PASS%"=="" (
  echo ERROR: DB password is empty.
  pause
  exit /b 1
)

echo.
echo [1/5] Upload backup bundle to NEW VM
scp -P %SSH_PORT% -i "%SSH_KEY%" "%BACKUP_BUNDLE%" %SSH_USER%@%NEW_IP%:/home/%SSH_USER%/pm_restore_bundle.tar.gz
if errorlevel 1 goto :error

echo [2/5] Upload remote restore script to NEW VM
scp -P %SSH_PORT% -i "%SSH_KEY%" "%REMOTE_RESTORE_SCRIPT%" %SSH_USER%@%NEW_IP%:/home/%SSH_USER%/pm_restore_remote.sh
if errorlevel 1 goto :error

echo [3/5] Run remote restore on NEW VM
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%NEW_IP% "chmod +x /home/%SSH_USER%/pm_restore_remote.sh && bash /home/%SSH_USER%/pm_restore_remote.sh /home/%SSH_USER%/pm_restore_bundle.tar.gz %NEW_IP% %NEW_HOSTNAME% '%DB_PASS%'"
if errorlevel 1 goto :error

echo [4/5] Update Windows hosts if this BAT is running as Administrator
net session >nul 2>&1
if errorlevel 1 (
  echo WARN: Not running as Administrator. Please update Windows hosts manually:
  echo %NEW_IP% pm.processmining tm.processmining %NEW_HOSTNAME%
) else (
  powershell -NoProfile -Command "$hosts='C:\Windows\System32\drivers\etc\hosts'; $lines=Get-Content $hosts | Where-Object {$_ -notmatch 'pm\.processmining' -and $_ -notmatch 'tm\.processmining'}; $lines + '%NEW_IP% pm.processmining tm.processmining %NEW_HOSTNAME%' | Set-Content $hosts -Encoding ascii"
  echo Windows hosts updated.
)

echo [5/5] Test PM endpoint from Windows
powershell -NoProfile -Command "Test-NetConnection pm.processmining -Port 443"
curl.exe -k -I https://pm.processmining

echo.
echo Restore completed.
echo Open: https://pm.processmining/signin
echo.
pause
exit /b 0

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
