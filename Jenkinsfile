pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '678b78dd-9891-4467-8518-975973b4c7c0'
        NETLIFY_AUTH_TOKEN = credentials('netlify_token')
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
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

        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                } 
            }
            steps {
                sh '''
                npm install netlify-cli
                node_modules/.bin/netlify --version
                echo "Deploying to production. project id: $NETLIFY_PROJECT_ID"
                node_modules/.bin/netlify status
                node_modules/.bin/netlify deploy --help
                node_modules/.bin/netlify deploy --dir=build --prod --no-build
                '''
            }
        }
    }
}
