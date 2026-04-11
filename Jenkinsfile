pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        // Default placeholders
        SONAR_PROJECT_KEY = "signaling-server"
    }

    stages {
        stage('Initialize & Run') {
            steps {
                script {
                    def envVars = []
                    
                    if (fileExists('.env')) {
                        echo "📝 Loading environment variables from .env..."
                        def envFile = readFile('.env')
                        envFile.split('\r?\n').each { line ->
                            line = line.trim()
                            if (line && !line.startsWith('#') && line.contains('=')) {
                                envVars.add(line)
                                echo "Queued: ${line.split('=')[0]}"
                            }
                        }
                    } else {
                        error "❌ .env file NOT found. This pipeline requires a local .env file for configuration."
                    }

                    // Wrap all subsequent stages in withEnv to ensure variables are available
                    withEnv(envVars) {
                        stage('Diagnostics') {
                            echo "🔍 Environment Diagnostics:"
                            echo "PATH (System): ${env.PATH}"
                            echo "FLUTTER_HOME: ${env.FLUTTER_HOME}"
                            echo "SONAR_HOST_URL: ${env.SONAR_HOST_URL}"
                            
                            // Check Docker
                            bat "docker --version || echo 'Docker not found'"
                        }

                        stage('SonarQube Analysis') {
                            echo "🚀 Running SonarQube Static Analysis using Docker..."
                            // We map the signaling_server directory to /usr/src inside the container
                            // We use host.docker.internal to reach the SonarQube server on the host
                            bat """
                                docker run --rm ^
                                -e SONAR_HOST_URL="${env.SONAR_HOST_URL}" ^
                                -e SONAR_TOKEN="${env.SONAR_TOKEN}" ^
                                -v "%WORKSPACE%\\signaling_server:/usr/src" ^
                                sonarsource/sonar-scanner-cli ^
                                -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} ^
                                -Dsonar.sources=.
                            """
                        }

                        stage('Clean & Build APK') {
                            echo '🛠️ Cleaning and building Mobile APK...'
                            // Use absolute path to flutter.bat to avoid PATH issues
                            def flutterCmd = "${env.FLUTTER_HOME}\\bin\\flutter.bat"
                            bat "${flutterCmd} clean"
                            bat "${flutterCmd} build apk --release"
                            archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk', fingerprint: true
                        }

                        stage('Docker Build & Push') {
                            echo '📦 Building Docker Image for Signaling Server...'
                            dir('signaling_server') {
                                // Build using the local Dockerfile
                                bat "docker build -t ${env.DOCKER_IMAGE} ."
                                
                                // Push to Registry
                                withCredentials([usernamePassword(credentialsId: 'docker-hub-login', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                                    bat "docker login -u ${USER} -p ${PASS}"
                                    bat "docker push ${env.DOCKER_IMAGE}"
                                }
                            }
                        }

                        stage('Deploy to OpenShift') {
                            echo '🚀 Triggering Orchestrated Deployment on OpenShift...'
                            withCredentials([string(credentialsId: 'oc-token', variable: 'TOKEN')]) {
                                bat "oc login ${env.OC_SERVER} --token=${TOKEN} --insecure-skip-tls-verify"
                                bat "oc project ${env.OC_PROJECT}"
                                bat "oc set image deployment/signaling-server signaling-server=${env.DOCKER_IMAGE}"
                                bat 'oc apply -f openshift/service.yaml'
                                bat 'oc rollout status deployment/signaling-server'
                            }
                        }
                    }
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
            echo '❌ Pipeline failed. Check logs for .env loading or Docker errors.'
        }
    }
}
