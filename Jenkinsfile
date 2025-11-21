pipeline {
  agent any

  environment {
    SONAR_TOKEN = credentials('SONAR_TOKEN') // existing secret text in Jenkins
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install') {
      steps {
        sh 'node -v || true'
        sh 'npm ci'
      }
    }

    stage('Test') {
      steps {
        // run tests (optional)
        sh 'npm test || true'
      }
    }

    stage('Sonar Analysis') {
      steps {
        script {
          // run sonar-scanner docker image and connect it to the docker network 'ci-network'
          sh """
            docker run --rm \
              --network ci-network \
              -v "\$(pwd)":/usr/src \
              -w /usr/src \
              sonarsource/sonar-scanner-cli \
              -Dsonar.projectKey=${JOB_NAME} \
              -Dsonar.sources=. \
              -Dsonar.host.url=http://sonarqube:9000 \
              -Dsonar.login=${SONAR_TOKEN}
          """
        }
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
