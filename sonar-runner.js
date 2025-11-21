// sonar-runner.js
// Robust loader for various versions of sonarqube-scanner package

let scannerModule;
try {
  scannerModule = require('sonarqube-scanner');
} catch (err) {
  console.error('Failed to require sonarqube-scanner:', err.message);
  process.exit(1);
}

// support both CommonJS function export and { default: fn } shapes
const scanner = (typeof scannerModule === 'function')
  ? scannerModule
  : (scannerModule && typeof scannerModule.default === 'function')
    ? scannerModule.default
    : null;

if (!scanner) {
  console.error('sonarqube-scanner module does not export a function. Module shape:', Object.keys(scannerModule || {}));
  process.exit(2);
}

const serverUrl = process.env.SONAR_HOST_URL || 'http://sonarqube:9000';
const token = process.env.SONAR_TOKEN || '';

scanner({
  serverUrl,
  token,
  options: {
    'sonar.projectKey': process.env.SONAR_PROJECT_KEY || 'node-app',
    'sonar.sources': '.',
    'sonar.sourceEncoding': 'UTF-8'
  }
}, () => {
  console.log('SonarQube scan finished');
});
