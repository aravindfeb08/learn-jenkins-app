pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        APP_NAME = 'learnjenkinsapp'
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ECS_CLUSTER = 'LeanJenkinsApp-Cluster-Prod'
        AWS_ECS_SERVICE_PROD = 'LearnJenkinsApp-TaskDefinition-Prod'
        AWS_ECS_TD_PROD = 'LearnJenkinsApp-TaskDefinition-Prod'
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

        // stage('Deploy To AWS S3') {
        //     agent {
        //         docker {
        //             image 'amazon/aws-cli'
        //             args "--entrypoint=''"
        //             reuseNode true
        //         }
        //     }
        //     environment {
        //         AWS_S3_BUCKET = 'aws-s3-demo-bucket-110920260101'
        //     }
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'jenkins-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        //             sh '''
        //             aws --version
        //             echo "Hello s3!" > index.html
        //             #aws s3 ls
        //             aws s3 cp index.html s3://$AWS_S3_BUCKET/index.html
        //             #aws s3 sync build s3://$AWS_S3_BUCKET
        //             '''
        //         }
        //     }
        // }
        stage('Build Docker Image') {
            agent {
                docker {
                    image 'my-aws-cli'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }
            steps {
                 withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        docker build -t $APP_NAME:$REACT_APP_VERSION .
                    '''
                }
            }
        }

        // stage('Deploy to AWS ECS') {
        //     agent {
        //         docker {
        //             image 'my-aws-cli'
        //             args "-u root --entrypoint=''"
        //             reuseNode true
        //         }
        //     }
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'jenkins-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        //             sh '''
        //             LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq '.taskDefinition.revision')
        //             echo $LATEST_TD_REVISION
        //             aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD --task-definition $AWS_ECS_TD_PROD:$LATEST_TD_REVISION
        //             aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
        //             '''
        //         }
        //     }
        // }
    }
}
