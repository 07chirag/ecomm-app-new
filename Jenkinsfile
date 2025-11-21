pipeline {
  agent any

  environment {
    SONAR_TOKEN = credentials('SONAR_TOKEN')   // make sure this credential exists in Jenkins
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
        // keep tests non-blocking for now (remove || true when you add real tests)
        sh 'npm test || true'
      }
    }

    stage('Sonar Analysis') {
      steps {
        // run sonar analysis inside the Jenkins Sonar configuration named "Sonar"
        withSonarQubeEnv('Sonar') {
          sh '''
            # install scanner for this run (keeps package.json unchanged)
            npm install --no-save sonarqube-scanner

            # export secrets & run the JS scanner
            export SONAR_TOKEN="$SONAR_TOKEN"
            export SONAR_HOST_URL="$SONAR_HOST_URL"
            export SONAR_PROJECT_KEY="$SONAR_PROJECT_KEY"

            node sonar-runner.js
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        // wait for SonarQube Quality Gate result (will abort pipeline if gate fails)
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }

  post {
    always {
      // collect basic logs/artifacts if needed
      archiveArtifacts artifacts: 'sonar-report/**', allowEmptyArchive: true
    }
  }
}
