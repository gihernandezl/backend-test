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
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh """
                    echo "$PASS" | docker login -u "$USER" --password-stdin
                    docker push ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                    docker push ${DOCKERHUB_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl set image deployment/backend-test backend-test=${DOCKERHUB_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} \
                    -n gihernandez --kubeconfig=${KUBECONFIG_PATH}
                """
            }
        }
    }

    post {
        success {
            echo "Despliegue exitoso,lpm!!Imagen: ${DOCKERHUB_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
        failure {
            echo "Falló el pipeline ya basta freezer!!"
        }
    }
}
