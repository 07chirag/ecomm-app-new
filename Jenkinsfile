pipeline {
  agent {
    docker { image 'node:20' }
  }

  environment {
    SONAR_TOKEN = credentials('SONAR_TOKEN')
    SONAR_HOST_URL = 'http://sonarqube:9000'
    SONAR_PROJECT_KEY = "${JOB_NAME}"
  }

  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Install Dependencies') {
      steps { sh 'npm ci' }
    }

    stage('Run Tests') {
      steps { sh 'npm test || true' }
    }

    stage('SonarQube Analysis') {
      steps {
        sh """
          export SONAR_TOKEN=${SONAR_TOKEN}
          export SONAR_HOST_URL=${SONAR_HOST_URL}
          export SONAR_PROJECT_KEY=${SONAR_PROJECT_KEY}
          node sonar-runner.js
        """
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
