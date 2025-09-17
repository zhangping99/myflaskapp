@echo off
chcp 65001 >nul  // Force UTF-8 encoding

:: --------------------------
:: Configuration (Modify according to your environment!)
:: --------------------------
set "JENKINS_WORKSPACE=C:\ProgramData\Jenkins\.jenkins\workspace\myflaskapp"
set "DEPLOY_DIR=D:\my-python-webapp-deploy"
set "PORT=5000"
set "PYTHON_PATH=d:\install\python310\python.exe"  // Path to your system's Python executable

echo ==============================================
echo Deployment Configuration
echo ==============================================
echo Jenkins Workspace: %JENKINS_WORKSPACE%
echo Deploy Directory: %DEPLOY_DIR%
echo Flask Port: %PORT%
echo System Python Path: %PYTHON_PATH%
echo ==============================================

:: 1. Stop existing Flask service
echo 1/5: Stopping existing Flask service...
taskkill /f /im python.exe /fi "windowtitle eq Flask Web App" 2>nul || echo "⚠️ No Flask service found"
taskkill /f /im python.exe /fi "commandline eq *%DEPLOY_DIR%\app.py*" 2>nul || echo "⚠️ No app process found"

:: 2. Initialize deploy directory
echo 2/5: Initializing deploy directory...
if not exist "%DEPLOY_DIR%" (
    mkdir "%DEPLOY_DIR%" && echo "✅ Deploy directory created: %DEPLOY_DIR%"
) else (
    del /q /s "%DEPLOY_DIR%\*" && echo "✅ Old files in deploy directory cleared"
)

:: 3. Copy code to deploy directory
echo 3/5: Copying code to deploy directory...
xcopy "%JENKINS_WORKSPACE%\app.py" "%DEPLOY_DIR%\" /y /q && echo "✅ app.py copied successfully" || (echo "❌ Failed to copy app.py" && exit /b 1)
xcopy "%JENKINS_WORKSPACE%\requirements.txt" "%DEPLOY_DIR%\" /y /q && echo "✅ requirements.txt copied successfully" || (echo "❌ Failed to copy requirements.txt" && exit /b 1)

:: 4. Verify Python environment
echo 4/5: Verifying Python environment...
"%PYTHON_PATH%" --version || (echo "❌ Invalid Python path! Check PYTHON_PATH" && exit /b 1)

:: 5. Start Flask service in background
echo 5/5: Starting Flask service...
start "Flask Web App" "%PYTHON_PATH%" "%DEPLOY_DIR%\app.py" || (echo "❌ Failed to start service! Check Python path or app.py" && exit /b 1)

:: 6. Verify deployment result
echo ==============================================
echo Verifying deployment (wait 3s to check port)
echo ==============================================
timeout /t 3 /nobreak >nul
netstat -ano | findstr :%PORT% >nul
if %errorlevel% equ 0 (
    echo [92m🎉 Deployment successful! Access: http://localhost:%PORT%[0m
) else (
    echo [91m❌ Deployment failed! Port %PORT% is not in use. Check:[0m
    echo 1. Python path: %PYTHON_PATH%
    echo 2. app.py syntax (run "%PYTHON_PATH%" "%DEPLOY_DIR%\app.py" manually)
    echo 3. Port %PORT% occupancy (use "netstat -ano | findstr :%PORT%" to check)
    exit /b 1
)