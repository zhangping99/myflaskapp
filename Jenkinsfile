pipeline {
    agent any
    
    tools {
        // 将Python名称改为小写的python3，匹配系统提示的可能名称
        'jenkins.plugins.shiningpanda.tools.PythonInstallation' 'python3'
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
