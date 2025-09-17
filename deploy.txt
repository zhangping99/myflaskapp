@echo off
:: 【关键修改】使用Jenkins工作目录的虚拟环境，不再重新创建
set "JENKINS_WORKSPACE=C:\ProgramData\Jenkins\.jenkins\workspace\myflaskapp"
set "DEPLOY_DIR=D:\my-python-webapp-deploy"
set "PORT=5000"
:: 直接使用Jenkins创建的虚拟环境Python（避免重新创建）
set "PYTHON_PATH=%JENKINS_WORKSPACE%\venv\Scripts\python.exe"

:: 1. 停止现有Flask服务（释放端口）
echo 正在停止现有Flask服务...
taskkill /f /im python.exe /fi "windowtitle eq Flask*" 2>nul
taskkill /f /im python.exe /fi "commandline eq *app.py*" 2>nul

:: 2. 初始化部署目录
echo 初始化部署目录...
if not exist "%DEPLOY_DIR%" mkdir "%DEPLOY_DIR%"
del /q /s "%DEPLOY_DIR%\*" 2>nul

:: 3. 复制代码+虚拟环境到部署目录（仅复制必要文件，减少耗时）
echo 复制代码和虚拟环境到部署目录...
xcopy "%JENKINS_WORKSPACE%\app.py" "%DEPLOY_DIR%\" /y /q  // 复制应用文件
xcopy "%JENKINS_WORKSPACE%\requirements.txt" "%DEPLOY_DIR%\" /y /q  // 复制依赖清单（备用）
xcopy "%JENKINS_WORKSPACE%\venv" "%DEPLOY_DIR%\venv\" /e /y /q  // 复制虚拟环境（避免重新安装）

:: 4. 直接使用复制的虚拟环境启动Flask服务（无需重新激活）
echo 启动Flask服务...
start "Flask Web App" "%DEPLOY_DIR%\venv\Scripts\python.exe" "%DEPLOY_DIR%\app.py"

:: 5. 验证部署
timeout /t 3 /nobreak >nul
netstat -ano | findstr :%PORT% >nul
if %errorlevel% equ 0 (
    echo [92m🎉 部署成功！Windows 访问：http://localhost:%PORT%[0m
) else (
    echo [91m❌ 部署失败！检查日志或端口是否被占用[0m
    exit /b 1
)