pipeline {
    agent any
    

    
    stages {
        stage('Install Dependencies') {
            steps {
                bat '''
                    @echo off
                    :: Kill remaining Python processes
                    echo "Killing remaining Python processes..."
                    taskkill /f /im python.exe 2>nul
                    
                    :: Create virtual environment
                    echo "Creating project virtual environment..."
                    python -m venv venv
                    
                    :: Activate virtual environment (使用双反斜杠转义)
                    echo "Activating virtual environment..."
                    call venv\\Scripts\\activate.bat  // 关键修改：\ → \\
                    
                    :: Upgrade pip
                    echo "Upgrading pip in virtual environment..."
                    python -m pip install --upgrade pip --user --quiet
                    
                    :: Install dependencies
                    echo "Installing project dependencies..."
                    pip install -r requirements.txt --quiet
                '''
            }
        }

        stage('Lint') {
            steps {
                bat '''
                    @echo off
                    call venv\\Scripts\\activate.bat  // 关键修改：\ → \\
                    pip install flake8 --quiet
                    flake8 app.py tests/
                '''
            }
        }

        stage('Test') {
            steps {
                bat '''
                    @echo off
                    call venv\\Scripts\\activate.bat  // 关键修改：\ → \\
                    pip install pytest coverage --quiet
                    pytest --cov=app tests/ --cov-report=html
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

        // 其他阶段保持不变...
        stage('Deploy') {
            steps {
                bat '''
                    @echo off
                    echo "Starting deployment script..."
                    call deploy.bat
                '''
            }
        }
    }
    
    post {
        success { echo "CI/CD pipeline completed successfully!" }
        failure { echo "CI/CD pipeline failed!" }
    }
}