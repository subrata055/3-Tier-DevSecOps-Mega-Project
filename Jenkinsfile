pipeline {
    agent any

    environment {
        PATH = "/usr/local/bin:/usr/bin:/bin:${env.PATH}"
    }

    stages {
        stage('Git Checkout') {
            steps {
                echo '==> Stage 1: Checking out code from repository...'
                checkout scm
            }
        }

        stage('Trivy FS Scan') {
            steps {
                echo '==> Stage 2: Scanning source code repository with Trivy...'
                // Scans the workspace files for misconfigurations and vulnerabilities
                sh 'trivy fs --severity HIGH,CRITICAL .'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '==> Stage 3: Running SonarQube Code Scan...'
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube-Server') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo '==> Stage 4: Checking Quality Gate Status...'
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to Quality Gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '==> Stage 5: Building container images using Docker Compose...'
                sh 'docker compose build'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                echo '==> Stage 6: Scanning built Docker images with Trivy...'
                // Scans images built by Docker Compose for HIGH and CRITICAL vulnerabilities
                sh 'trivy image --severity HIGH,CRITICAL 3-tier-devsecops-mega-project-frontend:latest || true'
                sh 'trivy image --severity HIGH,CRITICAL 3-tier-devsecops-mega-project-backend:latest || true'
            }
        }

        stage('Clean Old Container') {
            steps {
                echo '==> Stage 7: Stopping and removing old container instances...'
                sh 'docker compose down --volumes --remove-orphans || true'
            }
        }

        stage('Deployment') {
            steps {
                echo '==> Stage 8: Deploying new containers in detached mode...'
                sh 'docker compose up -d'
                sh 'docker compose ps'
            }
        }
    }

    post {
        always {
            echo '==> Cleaning up dangling/intermediate build images...'
            sh 'docker image prune -f || true'
        }
        failure {
            echo '==> Deployment failed! Fetching container logs...'
            sh 'docker compose logs --tail=50'
        }
    }
}




// pipeline {
//     agent any

//     environment {
//         PATH = "/usr/local/bin:/usr/bin:/bin:${env.PATH}"
//     }

//     stages {
//         stage('Git Checkout') {
//             steps {
//                 echo '==> Stage 1: Checking out code from repository...'
//                 checkout scm
//             }
//         }

//     stage('SonarQube Analysis') {
//             steps {
//                 echo '==> Stage 2: Running SonarQube Code Scan...'
//                 script {
//                     def scannerHome = tool 'SonarScanner'
//                     withSonarQubeEnv('SonarQube-Server') {
//                         sh "${scannerHome}/bin/sonar-scanner"
//                     }
//                 }
//             }
//         }

//         stage('Quality Gate') {
//             steps {
//                 echo '==> Stage 3: Checking Quality Gate Status...'
//                 timeout(time: 5, unit: 'MINUTES') {
//                     // Waits for SonarQube webhook to return status back to Jenkins
//                     script {
//                         def qg = waitForQualityGate()
//                         if (qg.status != 'OK') {
//                             error "Pipeline aborted due to Quality Gate failure: ${qg.status}"
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Build Docker Image') {
//             steps {
//                 echo '==> Stage 4: Building container images using Docker Compose...'
//                 sh 'docker compose build'
//             }
//         }

//         stage('Clean Old Container') {
//             steps {
//                 echo '==> Stage 5: Stopping and removing old container instances...'
//                 sh 'docker compose down --volumes --remove-orphans || true'
//             }
//         }

//         stage('Deployment') {
//             steps {
//                 echo '==> Stage 6: Deploying new containers in detached mode...'
//                 sh 'docker compose up -d'
//                 sh 'docker compose ps'
//             }
//         }
//     }

//     post {
//         always {
//             echo '==> Cleaning up dangling/intermediate build images...'
//             sh 'docker image prune -f || true'
//         }
//         failure {
//             echo '==> Deployment failed! Fetching container logs...'
//             sh 'docker compose logs --tail=50'
//         }
//     }
// }
