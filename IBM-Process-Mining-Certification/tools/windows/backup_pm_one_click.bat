@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM IBM Process Mining 2.0.3 one-click backup launcher for Windows
REM Run this from a local clone of the repo.
REM It converts the Linux script to LF, uploads it to the OLD/CURRENT VM,
REM executes it, then downloads the generated full backup bundle.
REM Do NOT commit generated backup bundles, certificates, keys, or dumps to GitHub.

REM ===== Edit these values =====
set "OLD_IP=<OLD_VM_PUBLIC_IP>"
set "SSH_PORT=2223"
set "SSH_USER=itzuser"
set "SSH_KEY=C:\IBM_PM\pem_ibmcloudvsi_download.pem"
set "LOCAL_BACKUP_DIR=C:\IBM_PM\backups"
REM ============================

set "SCRIPT_DIR=%~dp0"
set "LINUX_BACKUP_SCRIPT=%SCRIPT_DIR%..\linux\pm_backup_full.sh"
set "LINUX_BACKUP_SCRIPT_LF=%TEMP%\pm_backup_full_lf.sh"

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

echo [0/4] Convert Linux script to LF line endings
powershell -NoProfile -ExecutionPolicy Bypass -Command "$src='%LINUX_BACKUP_SCRIPT%'; $dst='%LINUX_BACKUP_SCRIPT_LF%'; $txt=[System.IO.File]::ReadAllText($src); $txt=$txt.Replace([string][char]13 + [string][char]10, [string][char]10); [System.IO.File]::WriteAllText($dst, $txt, [System.Text.UTF8Encoding]::new($false))"
if errorlevel 1 goto :error

echo [1/4] Upload backup script to OLD/CURRENT VM
scp -P %SSH_PORT% -i "%SSH_KEY%" "%LINUX_BACKUP_SCRIPT_LF%" %SSH_USER%@%OLD_IP%:/home/%SSH_USER%/pm_backup_full.sh
if errorlevel 1 goto :error

echo [2/4] Run backup script on OLD/CURRENT VM
ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "chmod +x /home/%SSH_USER%/pm_backup_full.sh && bash /home/%SSH_USER%/pm_backup_full.sh"
if errorlevel 1 goto :error

echo [3/4] Find latest backup bundle
set "REMOTE_BUNDLE="
for /f "usebackq delims=" %%F in (`ssh -p %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP% "ls -1t /home/%SSH_USER%/pm_full_backup_*.tar.gz /home/%SSH_USER%/pm_backup_*.tar.gz 2>/dev/null | head -1"`) do set "REMOTE_BUNDLE=%%F"

if "%REMOTE_BUNDLE%"=="" (
  echo ERROR: Could not find remote backup bundle.
  goto :error
)

echo Latest remote bundle: %REMOTE_BUNDLE%

echo [4/4] Download backup bundle to local folder
scp -P %SSH_PORT% -i "%SSH_KEY%" %SSH_USER%@%OLD_IP%:%REMOTE_BUNDLE% "%LOCAL_BACKUP_DIR%\"
if errorlevel 1 goto :error

for %%A in ("%REMOTE_BUNDLE%") do set "BUNDLE_NAME=%%~nxA"
set "LOCAL_BUNDLE=%LOCAL_BACKUP_DIR%\%BUNDLE_NAME%"

echo.
echo Backup completed successfully.
echo Local folder : %LOCAL_BACKUP_DIR%
echo Local bundle : %LOCAL_BUNDLE%
echo.
pause
exit /b 0

:error
echo.
echo Backup failed. Check the error above.
pause
exit /b 1
