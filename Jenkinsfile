pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'gihernandezl'
        IMAGE = "${DOCKERHUB_USER}/backend-test"
        IMAGE_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = "/var/jenkins_home/kubeconfig"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/gihernandezl/backend-test.git'
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
                    docker build -t ${IMAGE}:latest .
                    docker tag ${IMAGE}:latest ${IMAGE}:${IMAGE_TAG}
                """
            }
        }

        stage('DockerHub Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push ${IMAGE}:latest
                        docker push ${IMAGE}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    echo "➡ Usando KUBECONFIG en ${KUBECONFIG}"

                    kubectl --kubeconfig=${KUBECONFIG} set image \
                        deployment/backend-test backend-test=${IMAGE}:${IMAGE_TAG} \
                        -n gihernandez

                    echo "➡ Esperando rollout…"

                    kubectl --kubeconfig=${KUBECONFIG} rollout status \
                        deployment/backend-test -n gihernandez
                """
            }
        }
    }

    post {
        success {
            echo " Deployment completo: ${IMAGE}:${IMAGE_TAG}"
        }
        failure {
            echo " Pipeline falló. Revisar logs arriba."
        }
    }
}
