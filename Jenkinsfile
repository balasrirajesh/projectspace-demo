pipeline {
    agent any
    
    triggers {
        githubPush()
        pollSCM('* * * * *')
    }

    environment {
        JAVA_OPTS = "-Dhttps.protocols=TLSv1.2,TLSv1.3"
        
        // STATIC ENVIRONMENT (Hardcoded to match user system)
        FLUTTER_HOME = "C:\\dev\\flutter"
        ANDROID_HOME = "C:\\Users\\naren\\AppData\\Local\\Android\\Sdk"
        OC_PATH = "C:\\Users\\naren\\oc.exe"
        DOCKER_IMAGE = "rajesh200402/signaling-server:latest"
        
        // CONFIG
        OC_PROJECT = "23mh1a05n6-dev"
        OC_SERVER = "https://api.rm2.thpm.p1.openshiftapps.com:6443"
        SIGNALING_URL = "https://signaling-server-23mh1a05n6-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com"
    }

    stages {
        stage('Initialize & Diagnostics') {
            steps {
                echo "🔍 Environment Diagnostics:"
                echo "PATH (System): ${env.PATH}"
                echo "FLUTTER_HOME: ${env.FLUTTER_HOME}"
                echo "ANDROID_HOME: ${env.ANDROID_HOME}"
                bat "docker --version || echo 'Docker not found'"
            }
        }

        stage('Run Backend Tests') {
            steps {
                echo "🧪 Running Quality Gate test suite..."
                dir('signaling_server') {
                    bat "npm install"
                    bat "npm test"
                }
            }
        }

        stage('Clean & Build APK') {
            steps {
                echo '🛠️ Cleaning and building Mobile APK...'
                script {
                    def flutterCmd = "${env.FLUTTER_HOME}\\bin\\flutter.bat"
                    
                    // FORCE INJECTION: Inject the production signaling URL into the .env asset file
                    bat "echo SIGNALING_URL=${env.SIGNALING_URL} > .env"
                    echo "✅ Baked SIGNALING_URL into .env asset for APK build."

                    bat "git config --global --add safe.directory ${env.FLUTTER_HOME}"
                    bat "git config --global --add safe.directory %WORKSPACE%"
                    
                    bat "${flutterCmd} clean"
                    // Pass ANDROID_HOME explicitly just in case
                    withEnv(["ANDROID_HOME=${env.ANDROID_HOME}"]) {
                        bat "${flutterCmd} build apk --release"
                    }
                }
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk', fingerprint: true
            }
        }

        stage('Docker Build & Push') {
            steps {
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
        }

        stage('Deploy to OpenShift') {
            steps {
                echo '🚀 Triggering Orchestrated Deployment on OpenShift...'
                script {
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
