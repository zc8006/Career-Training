@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM IBM Process Mining 2.0.3 one-click backup launcher for Windows
REM Run this from a local clone of the repo.
REM It uploads the Linux backup script to the OLD VM, executes it, then downloads the generated bundle.
REM Do NOT commit generated backup bundles, certificates, keys, or dumps to GitHub.

REM ===== Edit these values =====
set "OLD_IP=<OLD_VM_PUBLIC_IP>"
set "SSH_PORT=2223"
set "SSH_USER=itzuser"
set "SSH_KEY=C:\IBM_PM\pem_ibmcloudvsi_download.pem"
set "LOCAL_BACKUP_DIR=%USERPROFILE%\IBM_PM_Backups"
REM ============================

set "SCRIPT_DIR=%~dp0"
set "LINUX_BACKUP_SCRIPT=%SCRIPT_DIR%..\linux\pm_backup_full.sh"

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

echo === IBM Process Mining one-click backup ===
echo OLD_IP          : %OLD_IP%
echo SSH_PORT        : %SSH_PORT%
echo SSH_USER        : %SSH_USER%
echo LOCAL_BACKUP_DIR: %LOCAL_BACKUP_DIR%
echo.

echo [1/4] Upload backup script to OLD VM
scp -P %SSH_PORT% -i "%SSH_KEY%" "%LINUX_BACKUP_SCRIPT%" %SSH_USER%@%OLD_IP%:/home/%SSH_USER%/pm_backup_full.sh
if errorlevel 1 goto :error

echo [2/4] Run backup script on OLD VM
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "chmod +x /home/%SSH_USER%/pm_backup_full.sh && /home/%SSH_USER%/pm_backup_full.sh"
if errorlevel 1 goto :error

echo [3/4] Find latest backup bundle
set "REMOTE_BUNDLE="
for /f "usebackq delims=" %%F in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "ls -1t /home/%SSH_USER%/pm_backup_*.tar.gz 2>/dev/null | head -1"`) do set "REMOTE_BUNDLE=%%F"

if "%REMOTE_BUNDLE%"=="" (
  echo ERROR: Could not find remote backup bundle.
  goto :error
)

echo Latest remote bundle: %REMOTE_BUNDLE%

echo [4/4] Download backup bundle to local folder
scp -P %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP%:%REMOTE_BUNDLE% "%LOCAL_BACKUP_DIR%\"
if errorlevel 1 goto :error

echo.
echo Backup completed successfully.
echo Local folder: %LOCAL_BACKUP_DIR%
echo.
pause
exit /b 0

:error
echo.
echo Backup failed. Check the error above.
pause
exit /b 1
