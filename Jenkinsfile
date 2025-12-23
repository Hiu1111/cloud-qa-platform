pipeline {
  agent any
  options { timestamps() }

  environment {
    MAVEN_OPTS = '-Dmaven.repo.local=.m2'
    headless = 'true'
    browser = 'chrome'
  }

  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Test') {
      steps {
        sh 'mvn -v'
        sh 'mvn -q test'
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          archiveArtifacts artifacts: 'target/surefire-reports/**', fingerprint: true, allowEmptyArchive: true
        }
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
}
