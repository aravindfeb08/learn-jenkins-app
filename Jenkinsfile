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
                    image 'node:22-alpine'
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

        stage('Deploy Staging') {
            agent {
                docker {
                    image 'node:22-alpine'
                    reuseNode true
                } 
            }
            steps {
                sh '''
                npm install netlify-cli node-jq
                #node_modules/.bin/netlify --version
                echo "Deploying to production. project id: $NETLIFY_PROJECT_ID"
                node_modules/.bin/netlify status
                #node_modules/.bin/netlify deploy --help
                node_modules/.bin/netlify deploy --dir=build --no-build --json > staging_output.json
                '''
                script {
                    env.STAGING_URL = sh(script:"node_modules/.bin/node-jq -r '.deploy_url' staging_output.json", returnStdout: true)
                }
                echo "Staging url = ${env.STAGING_URL}"
                echo "REACT_APP_VERSION = ${REACT_APP_VERSION}"
            }
        }

        stage('Staging E2e') {
            agent {
                docker {
                //image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                image 'mcr.microsoft.com/playwright:v1.62.0-noble'
                reuseNode true
                }
            }
            environment {
                //CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
            }
            steps {
                sh '''
                npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2e Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }        
        }
    }
}
