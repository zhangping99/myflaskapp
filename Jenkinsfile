pipeline {
    agent any
    
    // Tool configuration (match Jenkins Global Tool "Python3" name, path: d:\install\python310)
    tools {
        python 'Python3'
    }
    
    stages {
        // --------------------------
        // Install Dependencies Stage
        // --------------------------
        stage('Install Dependencies') {
            steps {
                bat '''
                    @echo off
                    :: 1. Kill remaining Python processes to release file locks
                    echo "Killing remaining Python processes..."
                    taskkill /f /im python.exe 2>nul
                    
                    :: 2. Create virtual environment in Jenkins workspace (no system dependency pollution)
                    echo "Creating project virtual environment..."
                    python -m venv venv
                    
                    :: 3. Activate virtual environment (Windows requires "call" for batch files)
                    echo "Activating virtual environment..."
                    call venv\Scripts\activate.bat
                    
                    :: 4. Upgrade pip in virtual environment (--user avoids system-level operations)
                    echo "Upgrading pip in virtual environment..."
                    python -m pip install --upgrade pip --user --quiet
                    
                    :: 5. Install project dependencies in virtual environment
                    echo "Installing project dependencies..."
                    pip install -r requirements.txt --quiet
                '''
            }
        }

        // --------------------------
        // Lint Stage (Code Quality Check)
        // --------------------------
        stage('Lint') {
            steps {
                bat '''
                    @echo off
                    call venv\Scripts\activate.bat
                    pip install flake8 --quiet
                    flake8 app.py tests/
                '''
            }
        }

        // --------------------------
        // Test Stage (With Coverage Report)
        // --------------------------
        stage('Test') {
            steps {
                bat '''
                    @echo off
                    call venv\Scripts\activate.bat
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

        // --------------------------
        // Build Stage (Optional)
        // --------------------------
        stage('Build') {
            steps {
                echo "Build completed. Virtual environment dependencies are ready for deployment."
            }
        }

        // --------------------------
        // Deploy Stage
        // --------------------------
        stage('Deploy') {
            steps {
                bat '''
                    @echo off
                    echo "Starting deployment script..."
                    call deploy.bat
                '''
            }
            post {
                success { echo "Application deployed successfully!" }
                failure { echo "Application deployment failed!" }
            }
        }
    }

    // --------------------------
    // Global Post Actions
    // --------------------------
    post {
        success { echo "CI/CD pipeline completed successfully!" }
        failure { echo "CI/CD pipeline failed!" }
    }
}