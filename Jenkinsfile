pipeline {
    agent any

    stages {
        stage('w/o docker') {
            steps {
                echo 'Hello World'
                sh '''
                    echo Without docker
                    #npm --version
                    ls -la
                    touch container-no.txt
                '''
            }
        }
        stage('w docker') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo with docker
                    npm --version
                    ls -la
                    touch container-yes.txt
                '''
            }
            
        }
    }
}
