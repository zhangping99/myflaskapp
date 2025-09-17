pipeline {
    agent any
    
    // 若已安装ShiningPanda插件，保留tools块（指定系统Python路径，用于创建虚拟环境）；否则移除（直接用系统Python）
    tools {
        python 'Python3'  // 此处“Python3”需与Jenkins全局工具配置的Python名称一致（路径指向d:\install\python310）
    }
    
    stages {
        // 【删除重复的Checkout阶段】保留Jenkins默认的“Declarative: Checkout SCM”即可
        
        // 【核心修改：Install Dependencies阶段】清理进程→创建虚拟环境→安装依赖
        stage('Install Dependencies') {
            steps {
                bat '''
                    @echo off
                    :: 1. 清理残留的Python进程（释放文件锁）
                    echo "正在清理残留Python进程..."
                    taskkill /f /im python.exe /fi "imagename eq python.exe" 2>nul
                    
                    :: 2. 在Jenkins工作目录创建虚拟环境（venv目录，隔离依赖）
                    echo "正在创建项目专属虚拟环境..."
                    python -m venv venv  // 在当前工作目录（C:\ProgramData\Jenkins\.jenkins\workspace\myflaskapp）创建venv
                    
                    :: 3. 激活虚拟环境（Windows下必须用call命令执行activate.bat）
                    echo "正在激活虚拟环境..."
                    call venv\Scripts\activate.bat
                    
                    :: 4. 升级虚拟环境中的pip（--user避免系统级操作，--quiet减少日志）
                    echo "正在升级虚拟环境中的pip..."
                    python -m pip install --upgrade pip --user --quiet
                    
                    :: 5. 在虚拟环境中安装项目依赖
                    echo "正在安装项目依赖..."
                    pip install -r requirements.txt --quiet
                '''
            }
        }
        
        // 【Lint阶段】同样使用虚拟环境中的flake8
        stage('Lint') {
            steps {
                bat '''
                    @echo off
                    call venv\Scripts\activate.bat  // 激活虚拟环境
                    pip install flake8 --quiet  // 安装到虚拟环境
                    flake8 app.py tests/  // 执行代码检查
                '''
            }
        }
        
        // 【Test阶段】使用虚拟环境中的pytest和coverage
        stage('Test') {
            steps {
                bat '''
                    @echo off
                    call venv\Scripts\activate.bat  // 激活虚拟环境
                    pip install pytest coverage --quiet  // 安装到虚拟环境
                    pytest --cov=app tests/ --cov-report=html  // 执行测试并生成覆盖率报告
                '''
            }
            post {
                always {
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'htmlcov',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
            }
        }
        
        // 【Build阶段】（若无需打包可保留空步骤，或删除）
        stage('Build') {
            steps {
                echo "构建完成（虚拟环境依赖已就绪，准备部署）..."
            }
        }
        
        // 【Deploy阶段】修改为使用项目虚拟环境启动服务（而非部署脚本重新创建虚拟环境）
        stage('Deploy') {
            steps {
                bat '''
                    @echo off
                    :: 调用部署脚本（后续需同步修改deploy.bat，使用Jenkins工作目录的虚拟环境）
                    echo "开始执行部署脚本..."
                    call deploy.bat
                '''
            }
            post {
                success { echo "应用部署成功！" }
                failure { echo "应用部署失败！" }
            }
        }
    }
    
    post {
        success { echo "CI/CD pipeline completed successfully!" }
        failure { echo "CI/CD pipeline failed!" }
    }
}