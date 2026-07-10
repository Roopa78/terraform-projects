pipeline {

    agent any

    stages {


        stage('Build Docker Image') {

            steps {
                sh 'docker build -t mywebsite .'
            }
        }


        stage('Docker Login') {

            steps {

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {

                    sh '''
                    echo $PASS | docker login \
                    -u $USER \
                    --password-stdin
                    '''

                }
            }
        }


        stage('Push Image') {

            steps {

                sh '''
                docker tag mywebsite roopaks/mywebsite:latest
                docker push roopaks/mywebsite:latest
                '''

            }
        }


        stage('Deploy') {

            steps {

                sh '''
                docker stop website || true
                docker rm website || true

                docker run -d \
                --name website \
                -p 80:80 \
                roopaks/mywebsite:latest
                '''

            }
        }

    }

}