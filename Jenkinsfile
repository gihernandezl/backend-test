pipeline {
    agent any
//config environment path
    environment {
        DOCKERHUB_REPO = "gihernandezl/backend-test"
        GH_REPO = "docker.pkg.github.com/gihernandezl/backend-test/backend-test"
        BUILD_TAG = "${BUILD_NUMBER}"
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
                sh 'npm test || true'    
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build || echo "No build step"'
            }
        }
//Docker image build
        stage('Docker Build Image') {
            steps {
                sh """
                docker build -t ${DOCKERHUB_REPO}:latest .
                docker tag ${DOCKERHUB_REPO}:latest ${DOCKERHUB_REPO}:${BUILD_TAG}
                """
            }
        }

        stage('DockerHub Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh """
                    echo "$PASS" | docker login -u "$USER" --password-stdin
                    docker push ${DOCKERHUB_REPO}:latest
                    docker push ${DOCKERHUB_REPO}:${BUILD_TAG}
                    """
                }
            }
        }

        stage('Push to GitHub Packages') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-packages', passwordVariable: 'GH_TOKEN', usernameVariable: 'GH_USER')]) {
                    sh """
                    echo $GH_TOKEN | docker login docker.pkg.github.com -u $GH_USER --password-stdin
                    docker tag ${DOCKERHUB_REPO}:latest ${GH_REPO}:latest
                    docker tag ${DOCKERHUB_REPO}:latest ${GH_REPO}:${BUILD_TAG}
                    docker push ${GH_REPO}:latest
                    docker push ${GH_REPO}:${BUILD_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl set image deployment/backend-test backend-test=${DOCKERHUB_REPO}:${BUILD_TAG} -n gihernandez
                """
            }
        }
    }
}
