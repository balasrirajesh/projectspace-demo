pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        // --- Flutter Config ---
        FLUTTER_HOME = "C:\\flutter" 
        PATH = "${FLUTTER_HOME}\\bin;${env.PATH}"
        
        // --- OpenShift Config (Update these in Jenkins) ---
        OC_PROJECT = "alumni-live"
        OC_SERVER = "https://api.cluster-url:6443" // Replace with your cluster API
        OC_TOKEN = "" // Store this in Jenkins Credentials!
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Clean & Verify') {
            steps {
                echo 'Cleaning build artifacts...'
                bat 'flutter clean'
                echo 'Checking Flutter environment status...'
                bat 'flutter doctor'
            }
        }

        stage('Build Mobile APK') {
            steps {
                echo 'Building Release APK...'
                bat 'flutter build apk --release'
                echo 'Archiving build artifacts...'
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk', fingerprint: true
            }
        }

        stage('Deploy to OpenShift') {
            when {
                expression { return env.OC_TOKEN != "" }
            }
            steps {
                echo '🚀 Deploying Signaling Server to OpenShift...'
                
                // 1. Authenticate & Select Project
                bat "oc login ${env.OC_SERVER} --token=${env.OC_TOKEN} --insecure-skip-tls-verify"
                bat "oc project ${env.OC_PROJECT}"
                
                // 2. Binary Build (Local code -> OpenShift Registry)
                // Note: Ensures signaling-server build config exists
                bat "oc get bc signaling-server || oc new-build --name signaling-server --binary=true"
                
                echo 'Starting Build from local directory...'
                bat "oc start-build signaling-server --from-dir=signaling_server --follow"
                
                // 3. Apply Manifests (Deployment, Service, Route)
                echo 'Applying Kubernetes manifests...'
                bat 'oc apply -f openshift/deployment.yaml'
                bat 'oc apply -f openshift/service.yaml'
                
                // 4. Verify Route
                echo 'Retrieving Public Route URL...'
                bat 'oc get route signaling-server'
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful! Check OpenShift Route for your new URL.'
        }
        failure {
            echo '❌ Pipeline failed. Check oc status or build logs.'
        }
    }
}
