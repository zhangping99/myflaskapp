@echo off
:: Windows Deployment Script for Jenkins
set "JENKINS_WORKSPACE=C:\ProgramData\Jenkins\.jenkins\workspace\myflaskapp"
set "DEPLOY_DIR=D:\my-python-webapp-deploy"
set "PORT=5000"
set "PYTHON_PATH=%JENKINS_WORKSPACE%\venv\Scripts\python.exe"

:: 1. Stop existing Flask service
echo Stopping existing Flask service...
taskkill /f /im python.exe /fi "windowtitle eq Flask*" 2>nul
taskkill /f /im python.exe /fi "commandline eq *app.py*" 2>nul

:: 2. Initialize deployment directory
echo Initializing deployment directory...
if not exist "%DEPLOY_DIR%" mkdir "%DEPLOY_DIR%"
del /q /s "%DEPLOY_DIR%\*" 2>nul

:: 3. Copy code and virtual environment to deployment directory
echo Copying code and virtual environment to deployment directory...
xcopy "%JENKINS_WORKSPACE%\app.py" "%DEPLOY_DIR%\" /y /q
xcopy "%JENKINS_WORKSPACE%\requirements.txt" "%DEPLOY_DIR%\" /y /q
xcopy "%JENKINS_WORKSPACE%\venv" "%DEPLOY_DIR%\venv\" /e /y /q

:: 4. Start Flask service with copied virtual environment
echo Starting Flask service...
start "Flask Web App" "%DEPLOY_DIR%\venv\Scripts\python.exe" "%DEPLOY_DIR%\app.py"

:: 5. Verify deployment
timeout /t 3 /nobreak >nul
netstat -ano | findstr :%PORT% >nul
if %errorlevel% equ 0 (
    echo [92mSuccess! Access via: http://localhost:%PORT%[0m
) else (
    echo [91mDeployment failed! Check logs or port occupancy.[0m
    exit /b 1
)