pipeline {
    agent any
    
    environment {
        // 关键：仅需在这里定义1次Python路径，后续全量引用
        PYTHON_PATH = 'D:\\install\\Python313\\python.exe'  // Windows路径（双反斜杠）
    }
    
    stages {
        // 1. 路径验证（1行引用变量，无需重复写路径）
        stage('Verify Python Path') {
            steps {
                bat """
                    @echo off
                    echo "=== 验证Python路径 ==="
                    ${PYTHON_PATH} --version  // 引用变量，自动填充路径
                    ${PYTHON_PATH} -m site    // 验证安装目录是否正确
                """
            }
        }

        // 2. 代码拉取
        stage('Checkout') {
            steps {
                git url: 'https://github.com/zhangping99/myflaskapp.git', branch: 'main'
            }
        }

        // 3. 修复pip（仅引用变量，代码更简洁）
        stage('Fix pip') {
            steps {
                bat """
                    @echo off
                    echo "=== 修复pip环境 ==="
                    ${PYTHON_PATH} -m ensurepip --upgrade  // 用变量调用Python
                """
            }
        }

        // 4. 安装依赖（统一用变量，避免重复路径）
        stage('Install Dependencies') {
            steps {
                bat """
                    @echo off
                    echo "=== 安装依赖 ==="
                    ${PYTHON_PATH} -m pip install --upgrade pip  // 用python -m pip避免路径问题
                    ${PYTHON_PATH} -m pip install -r requirements.txt
                """
            }
        }

        // 5. 代码检查（示例：flake8）
        stage('Lint') {
            steps {
                bat "${PYTHON_PATH} -m pip install flake8 && ${PYTHON_PATH} -m flake8 app.py tests/"
            }
        }

        // 6. 测试（示例：pytest）
        stage('Test') {
            steps {
                bat """
                    ${PYTHON_PATH} -m pip install pytest
                    ${PYTHON_PATH} -m pytest --cov=app tests/ --cov-report=html
                """
            }
            post {
                always { publishHTML(target: [allowMissing: false, alwaysLinkToLastBuild: false, keepAll: true, reportDir: 'htmlcov', reportFiles: 'index.html', reportName: 'Coverage Report']) }
            }
        }

        // 7. 构建（示例：pyinstaller）
        stage('Build') {
            steps {
                bat """
                    ${PYTHON_PATH} -m pip install pyinstaller
                    ${PYTHON_PATH} -m PyInstaller --onefile app.py  // 用python -m调用，无需写pyinstaller路径
                """
            }
        }

        // 8. 部署（示例：启动Flask）
        stage('Deploy') {
            steps {
                bat "start ${PYTHON_PATH} app.py"  // 直接引用变量启动
            }
        }
    }

    post {
        success { echo 'CI/CD pipeline completed successfully!' }
        failure { echo 'CI/CD pipeline failed!' }
    }
}