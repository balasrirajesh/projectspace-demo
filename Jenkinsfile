pipeline {
    agent any
    
    triggers {
        githubPush()
        pollSCM('* * * * *')
    }

    environment {
        JAVA_OPTS = "-Dhttps.protocols=TLSv1.2,TLSv1.3"
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

                    withEnv(envVars) {
                        stage('Diagnostics') {
                            echo "🔍 Environment Diagnostics:"
                            echo "PATH (System): ${env.PATH}"
                            echo "FLUTTER_HOME: ${env.FLUTTER_HOME}"
                            echo "SONAR_HOST_URL: ${env.SONAR_HOST_URL}"
                            bat "docker --version || echo 'Docker not found'"
                        }

                        // ─────────────────────────────────────────────────────
                        // QUALITY GATE STAGE 1: Run Tests
                        // ─────────────────────────────────────────────────────
                        stage('Run Backend Tests') {
                            echo "🧪 Running Quality Gate test suite..."
                            dir('signaling_server') {
                                bat "npm install"
                                bat "npm test"
                            }
                        }

                        stage('Clean & Build APK') {
                            echo '🛠️ Cleaning and building Mobile APK...'
                            def flutterCmd = "${env.FLUTTER_HOME}\\bin\\flutter.bat"
                            
                            // FORCE INJECTION: Inject the production signaling URL into the .env asset file
                            // This ensures the APK is hardcoded to the correct OpenShift endpoint
                            bat "echo SIGNALING_URL=https://signaling-server-balasrirajesh-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com > .env"
                            echo "✅ Baked SIGNALING_URL into .env asset for APK build."

                            bat "git config --global --add safe.directory ${env.FLUTTER_HOME}"
                            bat "git config --global --add safe.directory %WORKSPACE%"
                            
                            bat "${flutterCmd} clean"
                            bat "${flutterCmd} build apk --release"
                            archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk', fingerprint: true
                        }

                        stage('Docker Build & Push') {
                            echo '📦 Building Docker Image for Signaling Server...'
                            dir('signaling_server') {
                                bat "docker build --no-cache --pull -t ${env.DOCKER_IMAGE} ."
                                retry(3) {
                                    withCredentials([usernamePassword(credentialsId: 'docker-hub-login', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                                        bat "docker login -u ${USER} -p ${PASS}"
                                        bat "docker push ${env.DOCKER_IMAGE}"
                                    }
                                }
                            }
                        }

                        stage('Deploy to OpenShift') {
                            echo '🚀 Triggering Orchestrated Deployment on OpenShift...'
                            def ocCmd = env.OC_PATH ?: 'oc'
                            
                            withCredentials([string(credentialsId: 'oc-token', variable: 'TOKEN')]) {
                                bat "${ocCmd} login ${env.OC_SERVER} --token=\"${TOKEN}\" --insecure-skip-tls-verify"
                                bat "${ocCmd} project ${env.OC_PROJECT}"
                                bat "${ocCmd} apply -f openshift/mongodb.yaml"
                                bat "${ocCmd} apply -f openshift/deployment.yaml"
                                bat "${ocCmd} set image deployment/signaling-server signaling-server=${env.DOCKER_IMAGE}"
                                bat "${ocCmd} apply -f openshift/service.yaml"
                                bat "${ocCmd} rollout restart deployment/signaling-server"
                                bat "${ocCmd} rollout status deployment/signaling-server"
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
            // Archive the JUnit XML produced by jest-junit
            junit allowEmptyResults: true, testResults: 'signaling_server/test-results/junit.xml'
        }
        success {
            echo '✅ Full DevOps Pipeline completed successfully! Quality Gate PASSED.'
        }
        failure {
            echo '❌ Pipeline failed. Check Quality Gate results or build logs.'
        }
    }
}
