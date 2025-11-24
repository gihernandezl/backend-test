pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "gihernandezl"
        DOCKER_IMAGE = "backend-test"
        KUBECONFIG_PATH = "/var/jenkins_home/kubeconfig"
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
                docker build -t ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest .
                docker tag ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest ${DOCKERHUB_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                """
            }
        }

        stage('DockerHub Push') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-creds', variable: 'PASS')]) {
                    sh """
                    echo "$PASS" | docker login -u ${DOCKERHUB_USER} --password-stdin
                    docker push ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                    docker push ${DOCKERHUB_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
                }
            }
        }

        /*
        stage('Push to GitHub Packages') {
            steps {
                withCredentials([string(credentialsId: 'github-packages', variable: 'GH_TOKEN')]) {
                    sh """
                    echo "$GH_TOKEN" | docker login ghcr.io -u ${DOCKERHUB_USER} --password-stdin
                    docker tag ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest ghcr.io/${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                    docker tag ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest ghcr.io/${DOCKERHUB_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ghcr.io/${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                    docker push ghcr.io/${DOCKERHUB_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
