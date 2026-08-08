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

        stage('Build Docker Image') {
            steps {
                echo '==> Stage 2: Building container images using Docker Compose...'
                sh 'docker compose build'
            }
        }

        stage('Clean Old Container') {
            steps {
                echo '==> Stage 3: Stopping and removing old container instances...'
                sh 'docker compose down --volumes --remove-orphans || true'
            }
        }

        stage('Deployment') {
            steps {
                echo '==> Stage 4: Deploying new containers in detached mode...'
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
