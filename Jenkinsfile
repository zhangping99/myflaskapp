pipeline {
    agent any
    
    tools {
        // 使用完整的Python工具类名，与Jenkins插件要求匹配
        'jenkins.plugins.shiningpanda.tools.PythonInstallation' 'Python3'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/zhangping99/myflaskapp.git', branch: 'main'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                bat 'python -m pip install --upgrade pip'
                bat 'pip install -r requirements.txt'
            }
        }
        
        stage('Lint') {
            steps {
                bat 'pip install flake8'
                bat 'flake8 app.py tests/'
            }
        }
        
        stage('Test') {
            steps {
                bat 'pytest --cov=app tests/ --cov-report=html'
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
        
        stage('Build') {
            steps {
                bat 'pip install pyinstaller'
                bat 'pyinstaller --onefile app.py'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                // 根据实际需求添加部署命令
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
