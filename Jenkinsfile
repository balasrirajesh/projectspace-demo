pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        // --- Flutter Config ---
        FLUTTER_HOME = "C:\\dev\\flutter" 
        PATH = "${FLUTTER_HOME}\\bin;${env.PATH}"
        
        // --- OpenShift & Registry Config ---
        OC_PROJECT = "23mh1a05n6-dev"
        OC_SERVER = "https://api.rm2.thpm.p1.openshiftapps.com:6443"
        
        // --- DevOps Toolchain Config ---
        DOCKER_IMAGE = "rajesh200402/signaling-server:latest"
        SONAR_PROJECT_KEY = "signaling-server"
        SONAR_HOST_URL = "http://localhost:9000"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🚀 Running SonarQube Static Analysis...'
                // We run analysis specifically on the signaling server logic
                dir('signaling_server') {
                    withSonarQubeEnv('SonarQube') {
                        bat "sonar-scanner -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} -Dsonar.sources=. -Dsonar.host.url=${env.SONAR_HOST_URL}"
                    }
                }
            }
        }

        stage('Clean & Build APK') {
            steps {
                echo 'Cleaning and building Mobile APK...'
                bat 'flutter clean'
                bat 'flutter build apk --release'
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk', fingerprint: true
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo '📦 Building Docker Image for Signaling Server...'
                dir('signaling_server') {
                    script {
                        // Build using the local Dockerfile
                        bat "docker build -t ${env.DOCKER_IMAGE} ."
                        
                        // Push to Registry (Requires REGISTRY_USER/PASS credentials in Jenkins)
                        withCredentials([usernamePassword(credentialsId: 'docker-hub-login', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            bat "docker login -u ${USER} -p ${PASS}"
                            bat "docker push ${env.DOCKER_IMAGE}"
                        }
                    }
                }
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                echo '🚀 Triggering Orchestrated Deployment on OpenShift...'
                
                withCredentials([string(credentialsId: 'oc-token', variable: 'TOKEN')]) {
                    // 1. Authenticate
                    bat "oc login ${env.OC_SERVER} --token=${TOKEN} --insecure-skip-tls-verify"
                    bat "oc project ${env.OC_PROJECT}"
                    
                    // 2. Update Image
                    // This forces OpenShift to pull the new image from the registry
                    bat "oc set image deployment/signaling-server signaling-server=${env.DOCKER_IMAGE}"
                    
                    // 3. Apply changes (Services, Routes)
                    bat 'oc apply -f openshift/service.yaml'
                    
                    // 4. Verify rollout
                    bat 'oc rollout status deployment/signaling-server'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        success {
            echo '✅ Full DevOps Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for SonarQube or Docker push errors.'
        }
    }
}
