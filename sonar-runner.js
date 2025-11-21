// sonar-runner.js
const scanner = require('sonarqube-scanner');

scanner({
  serverUrl: process.env.SONAR_HOST_URL || 'http://sonarqube:9000',
  token: process.env.SONAR_TOKEN || '',
  options : {
    'sonar.projectKey': process.env.SONAR_PROJECT_KEY || 'node-app',
    'sonar.sources': '.',
    'sonar.sourceEncoding': 'UTF-8'
  }
}, () => {
  console.log('SonarQube scan finished');
});
