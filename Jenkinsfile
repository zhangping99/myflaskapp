pipeline {
    agent any  // Use Jenkins default build node (local server)
    
    // Define environment variables for consistent paths
    environment {
        PYTHON_PATH = 'd:\\install\\python310\\python.exe'  // Full path to Python executable
    }
    
    stages {
        // --------------------------
        // Stage 1: Checkout Code
        // Note: Jenkins already checks out code in Declarative: Checkout SCM stage
        // This stage can be removed or simplified
        // --------------------------
        stage('Checkout Code') {
            steps {
                echo "Starting to pull code from GitHub..."
                git(
                    url: 'https://github.com/zhangping99/myflaskapp.git',
                    branch: 'main',
                    credentialsId: 'aa'
                )
                echo "Code pulled successfully! Current workspace: ${env.WORKSPACE}"
            }
        }

        // --------------------------
        // Stage 2: Install Dependencies
        // --------------------------
        stage('Install Dependencies') {
            steps {
                bat '''
                    @echo off
                    chcp 65001 >nul  :: Force UTF-8 encoding to fix character issues
                    echo ==============================================
                    echo Verify current Python/pip version (must match system)
                    echo ==============================================
                    "%PYTHON_PATH%" --version || (echo "❌ Python command not found! Check PATH" && exit /b 1)
                    "%PYTHON_PATH%" -m pip --version || (echo "❌ pip command not found! Check Python installation" && exit /b 1)
                    
                    echo ==============================================
                    echo Kill remaining Python processes (release files/ports)
                    echo ==============================================
                    taskkill /f /im python.exe 2>nul || echo "⚠️ No remaining Python processes found, continuing"
                    
                    echo ==============================================
                    echo Upgrade pip and install project dependencies
                    echo ==============================================
                    "%PYTHON_PATH%" -m pip install --upgrade pip --quiet || (echo "❌ Failed to upgrade pip! Check network/permissions" && exit /b 1)
                    "%PYTHON_PATH%" -m pip install -r requirements.txt flake8 pytest coverage --quiet || (echo "❌ Failed to install dependencies! Check requirements.txt" && exit /b 1)
                    
                    echo ==============================================
                    echo Dependencies installed successfully! Installed packages:
                    echo ==============================================
                    "%PYTHON_PATH%" -m pip list | findstr /i "flask pytest flake8"
                '''
            }
        }

        // --------------------------
        // Stage 3: Code Style Check (flake8)
        // --------------------------
        stage('Code Lint (flake8)') {
            steps {
                bat '''
                    @echo off
                    chcp 65001 >nul  :: Force UTF-8 encoding
                    echo ==============================================
                    echo Execute code style check (flake8)
                    echo ==============================================
                    "%PYTHON_PATH%" -m flake8 app.py tests/ || (
                        echo "❌ Code style check failed! Please fix issues according to logs (e.g., blank lines, indentation)"
                        exit /b 1
                    )
                    echo "✅ Code style check passed! No PEP8 errors"
                '''
            }
        }

        // --------------------------
        // Stage 4: Automated Tests (pytest)
        // --------------------------
        stage('Run Tests (pytest)') {
            steps {
                bat '''
                    @echo off
                    chcp 65001 >nul  :: Force UTF-8 encoding
                    echo ==============================================
                    echo Execute automated tests (pytest) and generate coverage report
                    echo ==============================================
                    "%PYTHON_PATH%" -m pytest --cov=app tests/ --cov-report=html || (
                        echo "❌ Automated tests failed! Please check test cases or code logic"
                        exit /b 1
                    )
                    echo "✅ Automated tests passed! All test cases executed successfully"
                '''
            }
            // Display coverage report in Jenkins (requires HTML Publisher plugin)
            post {
                always {
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'htmlcov',
                        reportFiles: 'index.html',
                        reportName: 'Test Coverage Report'
                    ])
                }
            }
        }

        // --------------------------
        // Stage 5: Deploy Application
        // --------------------------
        stage('Deploy Application') {
            steps {
                bat '''
                    @echo off
                    chcp 65001 >nul  :: Force UTF-8 encoding
                    echo ==============================================
                    echo Execute deployment script (deploy.bat)
                    echo ==============================================
                    if not exist "deploy.bat" (
                        echo "❌ Deployment script deploy.bat not found! Please check project root directory"
                        exit /b 1
                    )
                    call deploy.bat || (
                        echo "❌ Deployment script execution failed! Please check deploy.bat logs"
                        exit /b 1
                    )
                    echo "✅ Application deployed successfully! Access address: http://localhost:5000"
                '''
            }
        }
    }

    // --------------------------
    // Global build results
    // --------------------------
    post {
        success {
            echo "🎉 Full CI/CD pipeline executed successfully!"
            // Optional: Add email notification (requires email plugin configuration)
            // emailext to: 'your-email@xxx.com', subject: 'Jenkins Build Success', body: 'Application deployed to http://localhost:5000'
        }
        failure {
            echo "❌ Full CI/CD pipeline execution failed! Please check each stage's logs for troubleshooting"
            // Optional: Add failure notification
            // emailext to: 'your-email@xxx.com', subject: 'Jenkins Build Failed', body: 'Failure logs: ${BUILD_URL}console'
        }
    }
}
