pipeline {
    agent any
    
    environment {
        PYTHON_PATH = 'D:\\install\\Python313\\python.exe'
        WORKSPACE_PATH = "${env.WORKSPACE}"
        DEPLOY_DIR = 'D:\\my-python-webapp-deploy'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo "Pulling code from GitHub..."
                git(
                    url: 'https://github.com/zhangping99/myflaskapp.git',
                    branch: 'main',
                    credentialsId: 'aa'
                )
            }
        }

        stage('Setup Environment') {
            steps {
                bat """
                    chcp 65001 >nul
                    echo Cleaning up previous processes...
                    taskkill /f /im python.exe 2>nul || echo No Python processes found
                    
                    echo Setting up Python environment...
                    "${env.PYTHON_PATH}" -m pip install --upgrade pip --quiet
                    "${env.PYTHON_PATH}" -m pip install -r requirements.txt flake8 pytest coverage --quiet
                """
            }
        }

        stage('Code Quality') {
            steps {
                bat """
                    chcp 65001 >nul
                    echo Running code style checks...
                    "${env.PYTHON_PATH}" -m flake8 app.py test/ || exit 1
                """
            }
        }

        stage('Run Tests') {
            steps {
                bat """
                    chcp 65001 >nul
                    echo Running tests with coverage...
                    "${env.PYTHON_PATH}" -m pytest --cov=app --cov-report=html test/ || exit 1
                """
            }
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

        stage('Deploy') {
            steps {
                bat """
                    chcp 65001 >nul
                    echo Deploying application...
                    
                    echo Stopping existing services...
                    taskkill /f /im python.exe 2>nul || echo No running services found
                    
                    echo Preparing deployment directory...
                    if not exist "${env.DEPLOY_DIR}" mkdir "${env.DEPLOY_DIR}"
                    xcopy "${env.WORKSPACE_PATH}\\app.py" "${env.DEPLOY_DIR}\\" /y /q
                    xcopy "${env.WORKSPACE_PATH}\\requirements.txt" "${env.DEPLOY_DIR}\\" /y /q
                    
                    echo Starting Flask application...
                    start "Flask Web App" "${env.PYTHON_PATH}" "${env.DEPLOY_DIR}\\app.py"
                    
                    timeout /t 5 /nobreak >nul
                    echo Checking if application is running...
                    netstat -ano | findstr :5000 >nul && echo ✅ Deployment successful! Access: http://localhost:5000 || echo ❌ Deployment failed!
                """
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline execution failed!"
        }
    }
}