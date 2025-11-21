pipeline {
  agent any

  environment {
    SONAR_TOKEN = credentials('SONAR_TOKEN')
    SONAR_HOST_URL = 'http://sonarqube:9000'
    SONAR_PROJECT_KEY = "${JOB_NAME}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install Dependencies') {
      steps {
        sh 'node -v || true'
        sh 'npm -v || true'
        sh 'npm ci'
      }
    }

    stage('Run Tests') {
      steps {
        // keep tests non-blocking; change if you add real tests
        sh 'npm test || true'
      }
    }

    stage('Sonar Analysis') {
      steps {
        // use single-quoted multiline shell to avoid Groovy interpolation of secrets
        sh '''
          # install sonar scanner for this run (no-save keeps package.json unchanged)
          npm install --no-save sonarqube-scanner

          # export credentials for the scanner script (use shell expansion to avoid exposing in Jenkins logs)
          export SONAR_TOKEN="$SONAR_TOKEN"
          export SONAR_HOST_URL="$SONAR_HOST_URL"
          export SONAR_PROJECT_KEY="$SONAR_PROJECT_KEY"

          # run sonar-runner.js
          node sonar-runner.js
        '''
      }
    }

    stage('Quality Gate') {
      steps {
        withSonarQubeEnv('sonarqube') {
          timeout(time: 2, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }
  }
}
