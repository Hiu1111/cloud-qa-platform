pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Test (API only)') {
      steps {
        sh 'mvn -v'
        sh 'mvn -q -Dtest=ApiSmokeTest test'
      }
    }

    stage('Upload Reports to S3') {
      when { expression { return env.S3_BUCKET != null && env.S3_BUCKET.trim() != '' } }
      steps {
        sh 'chmod +x scripts/upload-reports-to-s3.sh'
        sh 'scripts/upload-reports-to-s3.sh'
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
      archiveArtifacts artifacts: 'target/surefire-reports/**', fingerprint: true, allowEmptyArchive: true
    }
  }
}
