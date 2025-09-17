@echo off
chcp 65001 >nul  // 解决中文乱码问题（Jenkins日志中中文正常显示）

:: --------------------------
:: 配置项：根据你的实际环境修改！
:: --------------------------
set "JENKINS_WORKSPACE=C:\ProgramData\Jenkins\.jenkins\workspace\myflaskapp"  // Jenkins工作目录（从Jenkins项目页面查看）
set "DEPLOY_DIR=D:\my-python-webapp-deploy"  // 部署目录（建议与源码目录分离，避免冲突）
set "PORT=5000"  // Flask应用端口（需与app.py中的port一致）
set "PYTHON_PATH=d:\install\python310\python.exe"  // 你的系统Python路径（必须正确！用python --version查看路径）

echo ==============================================
echo 部署配置信息
echo ==============================================
echo Jenkins工作目录：%JENKINS_WORKSPACE%
echo 部署目录：%DEPLOY_DIR%
echo Flask端口：%PORT%
echo 系统Python路径：%PYTHON_PATH%
echo ==============================================

:: 1. 停止现有Flask服务（避免端口占用）
echo 1/5：停止现有Flask服务...
taskkill /f /im python.exe /fi "windowtitle eq Flask Web App" 2>nul || echo "⚠️  未找到Flask服务进程"
taskkill /f /im python.exe /fi "commandline eq *%DEPLOY_DIR%\app.py*" 2>nul || echo "⚠️  未找到应用进程"

:: 2. 初始化部署目录（清空旧文件）
echo 2/5：初始化部署目录...
if not exist "%DEPLOY_DIR%" (
    mkdir "%DEPLOY_DIR%" && echo "✅ 已创建部署目录：%DEPLOY_DIR%"
) else (
    del /q /s "%DEPLOY_DIR%\*" && echo "✅ 已清空部署目录旧文件"
)

:: 3. 复制代码到部署目录（仅复制必要文件）
echo 3/5：复制代码到部署目录...
xcopy "%JENKINS_WORKSPACE%\app.py" "%DEPLOY_DIR%\" /y /q && echo "✅ 复制app.py成功" || (echo "❌ 复制app.py失败" && exit /b 1)
xcopy "%JENKINS_WORKSPACE%\requirements.txt" "%DEPLOY_DIR%\" /y /q && echo "✅ 复制requirements.txt成功" || (echo "❌ 复制requirements.txt失败" && exit /b 1)

:: 4. （可选）验证部署目录的Python环境
echo 4/5：验证部署目录Python环境...
"%PYTHON_PATH%" --version || (echo "❌ Python路径错误！请检查PYTHON_PATH配置" && exit /b 1)

:: 5. 后台启动Flask服务（用start命令，避免阻塞Jenkins）
echo 5/5：启动Flask服务...
start "Flask Web App" "%PYTHON_PATH%" "%DEPLOY_DIR%\app.py" || (echo "❌ 启动服务失败！请检查Python路径或app.py" && exit /b 1)

:: 6. 验证部署结果（检查端口是否被占用）
echo ==============================================
echo 验证部署结果（等待3秒后检查端口）
echo ==============================================
timeout /t 3 /nobreak >nul
netstat -ano | findstr :%PORT% >nul
if %errorlevel% equ 0 (
    echo [92m🎉 部署成功！访问地址：http://localhost:%PORT%[0m
) else (
    echo [91m❌ 部署失败！端口%PORT%未被占用，请检查：[0m
    echo 1. Python路径是否正确：%PYTHON_PATH%
    echo 2. app.py是否存在语法错误（可手动执行"%PYTHON_PATH%" "%DEPLOY_DIR%\app.py"测试）
    echo 3. 端口%PORT%是否被其他程序占用（用netstat -ano | findstr :%PORT%查看）
    exit /b 1
)