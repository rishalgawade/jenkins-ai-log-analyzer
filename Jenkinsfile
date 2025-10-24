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
                }
                
                sh '''
                    if [ -f build.sh ]; then
                        chmod +x build.sh
                        ./build.sh 2>&1 | tee ${BUILD_LOG}
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
                echo "\n❌ BUILD FAILED - Running AI Analysis"
                
                sh """
                    if [ -f "${ANALYZER_SCRIPT}" ]; then
                        python3 ${ANALYZER_SCRIPT} ${BUILD_LOG} ${ANALYSIS_OUTPUT}
                        
                        if [ -f "${ANALYSIS_OUTPUT}" ]; then
                            echo "\n📊 AI ANALYSIS:"
                            cat ${ANALYSIS_OUTPUT}
                        fi
                    else
                        echo "❌ Analyzer script not found"
                    fi
                """
                
                archiveArtifacts artifacts: 'analysis.txt, build_log.txt',
                                 allowEmptyArchive: true
            }
        }
        
        success {
            echo "✅ BUILD SUCCESSFUL"
            archiveArtifacts artifacts: 'build_log.txt', allowEmptyArchive: true
        }
    }
}
