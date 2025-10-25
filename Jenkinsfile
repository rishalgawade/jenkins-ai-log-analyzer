pipeline {
    agent any
    
    environment {
        GEMINI_API_KEY = credentials('gemini-api-key')
        GITHUB_TOKEN = credentials('github-token')
        BUILD_LOG = "${WORKSPACE}/build_log.txt"
        ANALYSIS_OUTPUT = "${WORKSPACE}/analysis.txt"
        ANALYZER_SCRIPT = "/var/jenkins_home/ai-log-analyzer/analyze_log.py"
    }
    
    parameters {
        string(name: 'GITHUB_PR_NUMBER', defaultValue: '', description: 'Pull Request Number')
        string(name: 'GITHUB_REPO', defaultValue: 'rishalgawade/jenkins-ai-log-analyzer', description: 'GitHub Repository')
        string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Branch to build')
    }
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        ansiColor('xterm')
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "🔄 Checking out code..."
                    echo "Repository: ${params.GITHUB_REPO}"
                    echo "Branch: ${params.GIT_BRANCH}"
                }
                
                checkout scm
                sh 'git log -1 --oneline'
            }
        }
        
        stage('Build & Test') {
            steps {
                script {
                    echo "🔨 Running build..."
                    
                    // Capture output to file AND show in console
                    sh '''
                        if [ -f build.sh ]; then
                            chmod +x build.sh
                            
                            # Run build, save output to file, and display it
                            ./build.sh > ${BUILD_LOG} 2>&1
                            EXIT_CODE=$?
                            
                            # Display the log in Jenkins console
                            cat ${BUILD_LOG}
                            
                            # Exit with the same code as build.sh
                            exit $EXIT_CODE
                        else
                            echo "ERROR: build.sh not found" | tee ${BUILD_LOG}
                            exit 1
                        fi
                    '''
                }
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
                        sh """
                            echo "🤖 Running AI analysis..."
                            python3 ${ANALYZER_SCRIPT} \
                                ${BUILD_LOG} \
                                ${ANALYSIS_OUTPUT} || echo "AI analysis failed but continuing..."
                        """
                        
                        def analysisExists = fileExists("${ANALYSIS_OUTPUT}")
                        if (analysisExists) {
                            echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "📊 AI ANALYSIS RESULTS"
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                            def analysis = readFile("${ANALYSIS_OUTPUT}")
                            echo analysis
                            echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        }
                        
                        archiveArtifacts artifacts: 'analysis.txt, build_log.txt',
                                         allowEmptyArchive: true,
                                         onlyIfSuccessful: false
                        
                        echo "\n✅ Analysis complete!"
                        echo "📦 Artifacts: ${env.BUILD_URL}artifact/"
                        
                    } else {
                        echo "❌ AI analyzer script not found at ${ANALYZER_SCRIPT}"
                    }
                } else {
                    echo "⚠️  Build log not found at ${BUILD_LOG}"
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
            }
        }
        
        always {
            echo "\n🏁 Pipeline execution completed"
            echo "Build #${env.BUILD_NUMBER}"
            echo "Duration: ${currentBuild.durationString}"
        }
    }
}
