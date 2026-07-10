pipeline {

agent any

stages {

stage('Checkout') {
steps {git 'https://github.com/Roopa78/terraform-projects.git'
}
}


stage('Build Docker Image') {
steps {
sh 'docker build -t mywebsite .'
}
}


stage('Docker Login') {
steps {
sh 'docker login -u roopaks -p Roopasha@15'
}
}


stage('Push Image') {
steps {
sh 'docker tag mywebsite roopaks/mywebsite:latest'
sh 'docker push roopaks/mywebsite:latest'
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