pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '678b78dd-9891-4467-8518-975973b4c7c0'
        NETLIFY_AUTH_TOKEN = credentials('netlify_token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        } 

        stage('Deploy aws') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''"
                }
            }
            environment {
                AWS_S3_BUCKET = 'aws-s3-demo-bucket-110920260101'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'jenkins-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                    aws --version
                    echo "Hello s3!" > index.html
                    #aws s3 ls
                    aws s3 cp index.html s3://$AWS_S3_BUCKET/index.html
                    #aws s3 sync build s3://$AWS_S3_BUCKET
                    '''
                }
            }
        }

    }
}
