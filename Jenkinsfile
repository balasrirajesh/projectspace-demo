pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        // These will be overridden by the .env file in the Initialize stage
        OC_PROJECT = ""
        OC_SERVER = ""
        DOCKER_IMAGE = ""
        SONAR_PROJECT_KEY = "signaling-server"
        SONAR_HOST_URL = ""
        SONAR_SCANNER_CMD = "sonar-scanner" // Fallback to global path
        FLUTTER_HOME = ""
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    if (fileExists('.env')) {
                        echo "📝 Loading environment variables from .env..."
                        def envFile = readFile('.env')
                        envFile.split('\r?\n').each { line ->
                            line = line.trim()
                            if (line && !line.startsWith('#') && line.contains('=')) {
                                def parts = line.split('=', 2)
                                def key = parts[0].trim()
                                def value = parts[1].trim()
                                env."${key}" = value
                                echo "Loaded ${key}"
                            }
                        }
                    } else {
                        echo "⚠️ .env file NOT found. Using default/manual environment variables."
                    }
                    
                    // Update PATH with the loaded FLUTTER_HOME
                    if (env.FLUTTER_HOME) {
                        env.PATH = "${env.FLUTTER_HOME}\\bin;${env.PATH}"
                    }
                }
            }
        }
        stage('Diagnostics') {
            steps {
                script {
                    echo "🔍 Environment Diagnostics:"
                    echo "PATH: ${env.PATH}"
                    echo "FLUTTER_HOME: ${env.FLUTTER_HOME}"
                    echo "SONAR_SCANNER_CMD: ${env.SONAR_SCANNER_CMD}"
                    bat "where flutter || echo 'Flutter not in PATH'"
                    bat "where ${env.SONAR_SCANNER_CMD} || echo 'Sonar Scanner not found'"
                }
            }
        }
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "🚀 Running SonarQube Static Analysis using ${env.SONAR_SCANNER_CMD}..."
                dir('signaling_server') {
                    // Use a specific SonarQube environment name configured in Jenkins
                    withSonarQubeEnv('SonarQube') {
                        bat "${env.SONAR_SCANNER_CMD} -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} -Dsonar.sources=. -Dsonar.host.url=${env.SONAR_HOST_URL}"
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
