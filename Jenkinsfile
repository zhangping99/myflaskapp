pipeline {
    agent any
    
    stages {
        // 1. 验证路径阶段（关键！）
        stage('Verify Python313 Path') {
            steps {
                bat '''
                    @echo off
                    echo "=== 验证Python313路径 ==="
                    D:\\install\\Python313\\python.exe --version  // 必须显示Python 3.13.x
                    D:\\install\\Python313\\python.exe -m site    // 检查安装目录是否为D:\\install\\Python313
                '''
            }
        }

        // 2. 代码拉取阶段
        stage('Checkout') {
            steps {
                git url: 'https://github.com/zhangping99/myflaskapp.git', branch: 'main'
            }
        }

        // 3. 修复并验证pip阶段
        stage('Fix & Verify pip') {
            steps {
                bat '''
                    @echo off
                    echo "=== 修复pip环境 ==="
                    D:\\install\\Python313\\python.exe -m ensurepip --upgrade  // 强制重建pip
                    echo "=== 验证pip ==="
                    D:\\install\\Python313\\python.exe -m pip --version       // 必须显示pip版本
                '''
            }
        }

        // 4. 依赖安装阶段
        stage('Install Dependencies') {
            steps {
                bat '''
                    @echo off
                    echo "=== 使用Python313安装依赖 ==="
                    D:\\install\\Python313\\python.exe -m pip install --upgrade pip
                    D:\\install\\Python313\\python.exe -m pip install -r requirements.txt
                '''
            }
        }

        // 5. 代码检查阶段（示例）
        stage('Lint') {
            steps {
                bat 'D:\\install\\Python313\\python.exe -m pip install flake8 && D:\\install\\Python313\\Scripts\\flake8.exe app.py tests/'
            }
        }

        // 6. 测试阶段（示例）
        stage('Test') {
            steps {
                bat 'D:\\install\\Python313\\python.exe -m pip install pytest && D:\\install\\Python313\\Scripts\\pytest.exe --cov=app tests/'
            }
        }

        // 7. 构建阶段（示例）
        stage('Build') {
            steps {
                bat '''
                    D:\\install\\Python313\\python.exe -m pip install pyinstaller
                    D:\\install\\Python313\\Scripts\\pyinstaller.exe --onefile app.py
                '''
            }
        }

        // 8. 部署阶段（示例）
        stage('Deploy') {
            steps {
                bat 'start D:\\install\\Python313\\python.exe app.py'  // 启动Flask应用（根据实际需求调整）
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully!'
        }
        failure {
            echo 'CI/CD pipeline failed!'
        }
    }
}