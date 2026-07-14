pipeline {

    agent any

    stages {


        stage('Build Docker Image') {

            steps {
                sh 'docker build -t myweb ./app'
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
                docker tag myweb roopaks/myweb:latest
                docker push roopaks/myweb:latest
                '''

            }
        }


        stage('Deploy') {

            steps {

                sh '''

                docker run -d \
                --name website \
                -p 80:80 \
                roopaks/myweb:latest
                '''

            }
        }

    }

}