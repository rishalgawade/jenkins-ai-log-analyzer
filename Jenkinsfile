pipeline {
  agent any

  environment {
    AI_API_KEY = credentials('AI_API_KEY')
    GITHUB_TOKEN = credentials('github-token')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build (docker)') {
      steps {
        script {
          // run the build inside an OpenJDK Docker container and keep workspace files
          sh '''
          docker run --rm -v "$PWD":/workspace -w /workspace openjdk:17-jdk-slim \
            bash -lc "chmod +x build.sh && ./build.sh"
          '''
        }
      }
    }

  }

  post {
    failure {
      echo 'Build failed — running AI analysis and commenting on PR...'
      // clone central analyzer
      sh 'rm -rf scripts/ai-analyzer || true'
      sh 'git clone https://github.com/rishalgawade/ai-log-analyzer.git scripts/ai-analyzer'

      // run analysis using python docker image so no python needed on Jenkins host
      sh '''
      docker run --rm -v "$PWD":/workspace -w /workspace python:3.11 \
        bash -lc "pip install requests || true; python3 scripts/ai-analyzer/scripts/analyze_log.py logs/build_log.txt logs/analysis.txt"
      ''' || true

      script {
        def analysis = ''
        if (fileExists('logs/analysis.txt')) {
          analysis = readFile('logs/analysis.txt').trim()
        } else {
          analysis = "ERROR: analysis file not found or analysis failed."
        }

        // If this is a PR build, Jenkins sets CHANGE_ID and CHANGE_URL env vars (Multibranch Pipeline)
        if (env.CHANGE_ID) {
          def prNumber = env.CHANGE_ID
          // CHANGE_URL looks like https://github.com/owner/repo/pull/123
          def repo = env.CHANGE_URL.tokenize('/')[3..4].join('/')
          // escape JSON
          def body = analysis.replace('"','\\"').replace('\\n','\\\\n')
          sh """
          curl -s -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "{\\"body\\": \\"🤖 Jenkins AI Log Analysis:\\n${body}\\"}" \
            https://api.github.com/repos/${repo}/issues/${prNumber}/comments
          """
        } else {
          echo "No PR context found; cannot post comment."
          echo analysis
        }
      }
    }
  }
}
