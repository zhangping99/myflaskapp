pipeline {
    agent any  // 使用Jenkins默认的构建节点（本地服务器）
    
    stages {
        // --------------------------
        // 阶段1：拉取代码（Jenkins自动执行，无需额外配置）
        // --------------------------
        stage('Checkout Code') {
            steps {
                echo "开始从GitHub拉取代码..."
                git(
                    url: 'https://github.com/zhangping99/myflaskapp.git',  // 你的GitHub仓库地址
                    branch: 'main',  // 你的分支（通常是main）
                    credentialsId: 'github-pat-zhangping99'  // 你的Jenkins GitHub凭据ID（之前配置的PAT）
                )
                echo "代码拉取完成！当前工作目录：${env.WORKSPACE}"  // 打印工作目录，方便排查路径问题
            }
        }

        // --------------------------
        // 阶段2：安装依赖（用系统pip，含版本验证）
        // --------------------------
        stage('Install Dependencies') {
            steps {
                bat '''
                    @echo off
                    echo ==============================================
                    echo 验证当前Python/pip版本（确保与系统一致）
                    echo ==============================================
                    python --version || (echo "❌ Python命令不可用！检查环境变量" && exit /b 1)
                    pip --version || (echo "❌ pip命令不可用！检查Python环境变量" && exit /b 1)
                    
                    echo ==============================================
                    echo 清理残留Python进程（避免文件/端口占用）
                    echo ==============================================
                    taskkill /f /im python.exe 2>nul || echo "⚠️  未找到残留Python进程，继续执行"
                    
                    echo ==============================================
                    echo 升级pip并安装项目依赖
                    echo ==============================================
                    python -m pip install --upgrade pip --quiet || (echo "❌ pip升级失败！检查网络或权限" && exit /b 1)
                    pip install -r requirements.txt flake8 pytest coverage --quiet || (echo "❌ 依赖安装失败！检查requirements.txt" && exit /b 1)
                    
                    echo ==============================================
                    echo 依赖安装完成！已安装的依赖列表：
                    echo ==============================================
                    pip list | findstr /i "flask pytest flake8"  // 仅显示关键依赖，验证是否安装成功
                '''
            }
        }

        // --------------------------
        // 阶段3：代码风格检查（flake8，确保代码规范）
        // --------------------------
        stage('Code Lint (flake8)') {
            steps {
                bat '''
                    @echo off
                    echo ==============================================
                    echo 执行代码风格检查（flake8）
                    echo ==============================================
                    flake8 app.py tests/ || (
                        echo "❌ 代码风格检查失败！请根据日志修复（如空行、缩进问题）"
                        exit /b 1  // 检查失败则终止流程，避免后续无效执行
                    )
                    echo "✅ 代码风格检查通过！无PEP8错误"
                '''
            }
        }

        // --------------------------
        // 阶段4：自动化测试（pytest，确保功能正常）
        // --------------------------
        stage('Run Tests (pytest)') {
            steps {
                bat '''
                    @echo off
                    echo ==============================================
                    echo 执行自动化测试（pytest）并生成覆盖率报告
                    echo ==============================================
                    pytest --cov=app tests/ --cov-report=html || (
                        echo "❌ 自动化测试失败！请检查测试用例或代码逻辑"
                        exit /b 1
                    )
                    echo "✅ 自动化测试通过！所有用例执行成功"
                '''
            }
            // 测试完成后，在Jenkins中展示覆盖率报告（需安装HTML Publisher插件）
            post {
                always {
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'htmlcov',  // 覆盖率报告目录（pytest自动生成）
                        reportFiles: 'index.html',
                        reportName: 'Test Coverage Report'  // Jenkins中显示的报告名称
                    ])
                }
            }
        }

        // --------------------------
        // 阶段5：部署应用（调用deploy.bat，后台启动Flask）
        // --------------------------
        stage('Deploy Application') {
            steps {
                bat '''
                    @echo off
                    echo ==============================================
                    echo 执行部署脚本（deploy.bat）
                    echo ==============================================
                    if not exist "deploy.bat" (
                        echo "❌ 部署脚本deploy.bat不存在！请检查项目根目录"
                        exit /b 1
                    )
                    call deploy.bat || (
                        echo "❌ 部署脚本执行失败！请查看deploy.bat日志"
                        exit /b 1
                    )
                    echo "✅ 应用部署完成！访问地址：http://localhost:5000"
                '''
            }
        }
    }

    // --------------------------
    // 全局构建结果：成功/失败提示（可选：添加邮件通知）
    // --------------------------
    post {
        success {
            echo "🎉 全流程CI/CD执行成功！"
            // （可选）添加邮件通知，需先配置Jenkins邮件插件
            // emailext to: 'your-email@xxx.com', subject: 'Jenkins构建成功', body: '应用已部署到http://localhost:5000'
        }
        failure {
            echo "❌ 全流程CI/CD执行失败！请查看各阶段日志排查问题"
            // （可选）失败时发送邮件通知
            // emailext to: 'your-email@xxx.com', subject: 'Jenkins构建失败', body: '失败日志：${BUILD_URL}console'
        }
    }
}