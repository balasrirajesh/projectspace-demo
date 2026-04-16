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
                        // QUALITY GATE STAGE 1: Run Tests & Generate Coverage
                        // This must happen BEFORE the SonarQube scan so that
                        // coverage reports exist for SonarQube to read.
                        // ─────────────────────────────────────────────────────
                        stage('Run Backend Tests') {
                            echo "🧪 Running Quality Gate test suite..."
                            dir('signaling_server') {
                                bat "npm install"
                                bat "npm test"
                            }
                        }

                        // ─────────────────────────────────────────────────────
                        // QUALITY GATE STAGE 2: SonarQube Static Analysis
                        // Must run inside withSonarQubeEnv so Jenkins can
                        // register the analysis task and waitForQualityGate()
                        // knows which result to poll for.
                        // ─────────────────────────────────────────────────────
                        stage('SonarQube Analysis') {
                            echo "🚀 Running SonarQube Static Analysis with Coverage..."
                            withSonarQubeEnv('SonarQube') {
                                bat """
                                    docker run --rm ^
                                    -e SONAR_HOST_URL="http://host.docker.internal:9000" ^
                                    -e SONAR_TOKEN="${env.SONAR_TOKEN}" ^
                                    -v "%WORKSPACE%\\signaling_server:/usr/src" ^
                                    sonarsource/sonar-scanner-cli ^
                                    -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} ^
                                    -Dsonar.sources=. ^
                                    -Dsonar.tests=tests ^
                                    -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info ^
                                    -Dsonar.exclusions=**/node_modules/**,**/tests/**,**/coverage/**
                                """
                            }
                        }

                        // ─────────────────────────────────────────────────────
                        // QUALITY GATE STAGE 3: ENFORCE THE GATE
                        // This step polls SonarQube for the quality gate result.
                        // If SonarQube says FAILED, the entire pipeline STOPS
                        // here and does NOT build the APK or deploy to production.
                        // ─────────────────────────────────────────────────────
                        stage('Quality Gate') {
                            echo "🛡️ Waiting for SonarQube Quality Gate result..."
                            timeout(time: 5, unit: 'MINUTES') {
                                def qg = waitForQualityGate()
                                if (qg.status != 'OK') {
                                    error "❌ QUALITY GATE FAILED: Status=${qg.status}. Fix all issues before deploying to production."
                                }
                            }
                            echo "✅ Quality Gate PASSED — Code is production-ready!"
                        }

                        stage('Clean & Build APK') {
                            echo '🛠️ Cleaning and building Mobile APK...'
                            def flutterCmd = "${env.FLUTTER_HOME}\\bin\\flutter.bat"
                            
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
