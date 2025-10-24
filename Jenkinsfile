pipeline {
    agent any
    
    environment {
        GEMINI_API_KEY = credentials('gemini-api-key')
        GITHUB_TOKEN = credentials('github-token')
        BUILD_LOG = "${WORKSPACE}/build_log.txt"
        ANALYSIS_OUTPUT = "${WORKSPACE}/analysis.txt"
        ANALYZER_SCRIPT = "/var/jenkins_home/ai-log-analyzer/analyze_and_comment.py"
    }
    
    parameters {
        string(name: 'GITHUB_PR_NUMBER', defaultValue: '', description: 'Pull Request Number')
        string(name: 'GITHUB_REPO', defaultValue: 'rishalgawade/jenkins-ai-log-analyzer', description: 'GitHub Repository (owner/repo)')
        string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Branch to build')
    }
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        ansiColor('xterm')
    }
    
    stages {
        stage('🔍 Checkout') {
            steps {
                script {
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "📥 CHECKING OUT CODE"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "Repository: ${params.GITHUB_REPO}"
                    echo "Branch: ${params.GIT_BRANCH}"
                    
                    if (params.GITHUB_PR_NUMBER) {
                        echo "Pull Request: #${params.GITHUB_PR_NUMBER}"
                    }
                }
                
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        url: "https://github.com/${params.GITHUB_REPO}.git",
                        credentialsId: 'github-credentials'
                    ]]
                ])
                
                sh '''
                    echo "\n📌 Latest commit:"
                    git log -1 --oneline
                    echo "\n📂 Workspace contents:"
                    ls -la
                '''
            }
        }
        
        stage('🛠️ Setup') {
            steps {
                script {
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "⚙️  ENVIRONMENT SETUP"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                }
                
                sh '''
                    echo "Current directory: $(pwd)"
                    echo "User: $(whoami)"
                    echo "Python version: $(python3 --version)"
                    echo "pip version: $(pip3 --version)"
                    
                    # Check if AI analyzer script is accessible
                    if [ -f "${ANALYZER_SCRIPT}" ]; then
                        echo "✅ AI analyzer script found"
                    else
                        echo "❌ AI analyzer script NOT found at ${ANALYZER_SCRIPT}"
                    fi
                '''
            }
        }
        
        stage('🔨 Build & Test') {
            steps {
                script {
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "🏗️  BUILDING PROJECT"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                }
                
                sh '''
                    # Try different build methods based on project type
                    if [ -f build.sh ]; then
                        echo "📜 Found build.sh - executing..."
                        chmod +x build.sh
                        ./build.sh 2>&1 | tee ${BUILD_LOG}
                        
                    elif [ -f package.json ]; then
                        echo "📦 Node.js project detected"
                        npm install 2>&1 | tee ${BUILD_LOG}
                        npm test 2>&1 | tee -a ${BUILD_LOG}
                        
                    elif [ -f requirements.txt ]; then
                        echo "🐍 Python project detected"
                        pip3 install -r requirements.txt 2>&1 | tee ${BUILD_LOG}
                        
                        if [ -d tests ]; then
                            pytest tests/ 2>&1 | tee -a ${BUILD_LOG} || \
                            python3 -m unittest discover tests/ 2>&1 | tee -a ${BUILD_LOG}
                        fi
                        
                    elif [ -f pom.xml ]; then
                        echo "☕ Maven project detected"
                        mvn clean test 2>&1 | tee ${BUILD_LOG}
                        
                    elif [ -f gradlew ]; then
                        echo "🐘 Gradle project detected"
                        ./gradlew clean test 2>&1 | tee ${BUILD_LOG}
                        
                    else
                        echo "❌ No build configuration found!"
                        echo "Please add one of: build.sh, package.json, requirements.txt, pom.xml, or build.gradle"
                        echo "ERROR: No build script found" | tee ${BUILD_LOG}
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        failure {
            script {
                echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "❌ BUILD FAILED"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🤖 Initiating AI-powered log analysis...\n"
                
                def logExists = fileExists("${BUILD_LOG}")
                
                if (logExists) {
                    echo "✅ Build log captured successfully"
                    
                    def scriptExists = fileExists("${ANALYZER_SCRIPT}")
                    
                    if (scriptExists) {
                        // Run AI analysis with or without GitHub PR commenting
                        if (params.GITHUB_PR_NUMBER && params.GITHUB_REPO) {
                            echo "📝 Running AI analysis with GitHub PR integration..."
                            sh """
                                python3 ${ANALYZER_SCRIPT} \
                                    ${BUILD_LOG} \
                                    ${params.GITHUB_REPO} \
                                    ${params.GITHUB_PR_NUMBER} \
                                    ${ANALYSIS_OUTPUT}
                            """
                        } else {
                            echo "⚠️  No PR information provided - running analysis without GitHub comment"
                            sh """
                                python3 /var/jenkins_home/ai-log-analyzer/analyze_log.py \
                                    ${BUILD_LOG} \
                                    ${ANALYSIS_OUTPUT}
                            """
                        }
                        
                        // Display analysis in console
                        def analysisExists = fileExists("${ANALYSIS_OUTPUT}")
                        if (analysisExists) {
                            echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "📊 AI ANALYSIS RESULTS"
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                            def analysis = readFile("${ANALYSIS_OUTPUT}")
                            echo analysis
                            echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        }
                        
                        // Archive artifacts
                        archiveArtifacts artifacts: 'analysis.txt, build_log.txt',
                                         allowEmptyArchive: true,
                                         onlyIfSuccessful: false
                        
                        echo "\n✅ Analysis complete!"
                        echo "📦 Artifacts available at: ${env.BUILD_URL}artifact/"
                        
                    } else {
                        echo "❌ Error: AI analyzer script not found at ${ANALYZER_SCRIPT}"
                        echo "Please check Docker volume mounting configuration"
                    }
                } else {
                    echo "⚠️  Warning: Build log not found at ${BUILD_LOG}"
                    echo "Cannot perform AI analysis without build logs"
                }
            }
        }
        
        success {
            script {
                echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "✅ BUILD SUCCESSFUL"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                
                def logExists = fileExists("${BUILD_LOG}")
                if (logExists) {
                    archiveArtifacts artifacts: 'build_log.txt',
                                     allowEmptyArchive: true,
                                     onlyIfSuccessful: true
                }
                
                echo "🎉 All tests passed!"
                echo "Build URL: ${env.BUILD_URL}"
            }
        }
        
        always {
            script {
                echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🏁 PIPELINE COMPLETE"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "Build #${env.BUILD_NUMBER}"
                echo "Duration: ${currentBuild.durationString}"
                echo "Artifacts: ${env.BUILD_URL}artifact/"
                echo "Console: ${env.BUILD_URL}console"
            }
        }
    }
}