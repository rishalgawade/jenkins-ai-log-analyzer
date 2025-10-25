pipeline {
    agent any
    
    environment {
        GEMINI_API_KEY = credentials('gemini-api-key')
        GITHUB_TOKEN = credentials('github-token')
        BUILD_LOG = "${WORKSPACE}/build_log.txt"
        ANALYSIS_OUTPUT = "${WORKSPACE}/analysis.txt"
        ANALYZER_SCRIPT = "/var/jenkins_home/ai-log-analyzer/analyze_and_comment.py"
        ANALYZER_SCRIPT_SIMPLE = "/var/jenkins_home/ai-log-analyzer/analyze_log.py"
        
        GITHUB_PR_NUMBER = "${env.CHANGE_ID ?: ''}"
        GITHUB_REPO = "rishalgawade/jenkins-ai-log-analyzer"
        GIT_BRANCH = "${env.BRANCH_NAME ?: 'main'}"
        GITHUB_COMMIT = "${env.GIT_COMMIT}"
    }
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        ansiColor('xterm')
        // Removed gitHubStatusContext - it's not a valid option
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "📥 CHECKING OUT CODE"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "Repository: ${GITHUB_REPO}"
                    echo "Branch: ${GIT_BRANCH}"
                    
                    if (env.CHANGE_ID) {
                        echo "Pull Request: #${env.CHANGE_ID}"
                        updateGitHubStatus('pending', 'Build in progress...')
                    }
                }
                
                checkout scm
                sh 'git log -1 --oneline'
            }
        }
        
        stage('Build & Test') {
            steps {
                script {
                    echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "🔨 BUILDING PROJECT"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                }
                
                sh '''
                    if [ -f build.sh ]; then
                        chmod +x build.sh
                        ./build.sh > ${BUILD_LOG} 2>&1
                        EXIT_CODE=$?
                        cat ${BUILD_LOG}
                        exit $EXIT_CODE
                    else
                        echo "ERROR: build.sh not found" | tee ${BUILD_LOG}
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        failure {
            script {
                // Update GitHub status to failure
                if (env.CHANGE_ID) {
                    updateGitHubStatus('failure', 'Build failed - AI analysis available')
                }
                
                echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "❌ BUILD FAILED"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🤖 Initiating AI-powered log analysis...\n"
                
                def logExists = fileExists("${BUILD_LOG}")
                
                if (logExists) {
                    echo "✅ Build log captured"
                    
                    if (env.CHANGE_ID) {
                        echo "📝 Posting AI analysis to GitHub PR #${env.CHANGE_ID}..."
                        
                        def scriptExists = fileExists("${ANALYZER_SCRIPT}")
                        
                        if (scriptExists) {
                            sh """
                                python3 ${ANALYZER_SCRIPT} \
                                    ${BUILD_LOG} \
                                    ${GITHUB_REPO} \
                                    ${env.CHANGE_ID} \
                                    ${ANALYSIS_OUTPUT} || echo "⚠️  Analysis failed"
                            """
                        } else {
                            echo "⚠️  Using simple analyzer (no GitHub comment)"
                            sh "python3 ${ANALYZER_SCRIPT_SIMPLE} ${BUILD_LOG} ${ANALYSIS_OUTPUT} || true"
                        }
                    } else {
                        sh "python3 ${ANALYZER_SCRIPT_SIMPLE} ${BUILD_LOG} ${ANALYSIS_OUTPUT} || true"
                    }
                    
                    // Display analysis in Jenkins console
                    def analysisExists = fileExists("${ANALYSIS_OUTPUT}")
                    if (analysisExists) {
                        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        echo "📊 AI ANALYSIS RESULTS"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
                        echo readFile("${ANALYSIS_OUTPUT}")
                        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    }
                    
                    archiveArtifacts artifacts: 'analysis.txt, build_log.txt',
                                     allowEmptyArchive: true,
                                     onlyIfSuccessful: false
                    
                    if (env.CHANGE_ID) {
                        echo "\n💬 Check GitHub PR: https://github.com/${GITHUB_REPO}/pull/${env.CHANGE_ID}"
                    }
                }
            }
        }
        
        success {
            script {
                // Update GitHub status to success
                if (env.CHANGE_ID) {
                    updateGitHubStatus('success', 'Build passed successfully!')
                }
                
                echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "✅ BUILD SUCCESSFUL 🎉"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                
                archiveArtifacts artifacts: 'build_log.txt', 
                                 allowEmptyArchive: true,
                                 onlyIfSuccessful: true
            }
        }
        
        always {
            echo "\n🏁 Pipeline completed - Build #${env.BUILD_NUMBER}"
            echo "Duration: ${currentBuild.durationString}"
        }
    }
}

// Helper function to update GitHub commit status
def updateGitHubStatus(String state, String description) {
    if (!env.GITHUB_COMMIT) {
        echo "⚠️  No commit SHA available, skipping status update"
        return
    }
    
    try {
        sh """
            curl -X POST \
            -H "Authorization: token \${GITHUB_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/${GITHUB_REPO}/statuses/${env.GITHUB_COMMIT} \
            -d '{
                "state": "${state}",
                "target_url": "${env.BUILD_URL}console",
                "description": "${description}",
                "context": "continuous-integration/jenkins"
            }' || echo "Failed to update GitHub status"
        """
        echo "✅ GitHub status updated: ${state}"
    } catch (Exception e) {
        echo "⚠️  Failed to update GitHub status: ${e.message}"
    }
}
