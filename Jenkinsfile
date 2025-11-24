pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "gihernandezl"
        DOCKERHUB_PASS = credentials('dockerhub-pass')
        GH_TOKEN = credentials('github-token')
        IMAGE_NAME = "backend-test"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/gihernandezl/backend-test.git'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Testing') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker Build Image') {
            steps {
                sh """
                    docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest .
                    docker tag ${DOCKERHUB_USER}/${IMAGE_NAME}:latest ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        stage('DockerHub Push') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login -u ${DOCKERHUB_USER} --password-stdin
                        docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                        docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Push to GitHub Packages') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GHT')]) {
                    sh """
                        echo "$GHT" | docker login ghcr.io -u ${DOCKERHUB_USER} --password-stdin

                        docker tag ${DOCKERHUB_USER}/${IMAGE_NAME}:latest ghcr.io/${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                        docker tag ${DOCKERHUB_USER}/${IMAGE_NAME}:latest ghcr.io/${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}

                        docker push ghcr.io/${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                        docker push ghcr.io/${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    /usr/local/bin/kubectl set image deployment/backend-test backend-test=${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER} -n gihernandez --kubeconfig=/var/jenkins_home/kubeconfig
                """
            }
        }
    }
}
