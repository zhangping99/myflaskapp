pipeline {
    agent any
    
    tools {
        // 修正工具类型为pythonInstallation，与ShiningPanda插件兼容
        pythonInstallation 'Python3'  // 名称需与全局工具配置中的Python名称一致
    }
    
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/yourusername/yourrepo.git', branch: 'main'
                // 替换为你的代码仓库地址
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
                // 如果需要打包成可执行文件或部署包
                bat 'pip install pyinstaller'
                bat 'pyinstaller --onefile app.py'
            }
        }
        
        stage('Deploy') {
            steps {
                // 这里根据实际部署需求编写部署脚本
                echo 'Deploying application...'
                // 示例：启动应用
                // bat 'start python app.py'
            }
        }
    }
    
    post {
        success {
            echo 'CI/CD pipeline completed successfully!'
            // 可以配置邮件通知
        }
        failure {
            echo 'CI/CD pipeline failed!'
            // 可以配置邮件通知
        }
    }
}
