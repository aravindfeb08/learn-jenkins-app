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

        stage('Test') {
            parallel {
                stage('Unit test') {
                    agent {
                        docker {
                            image 'node:22-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                        test -f build/index.html
                        npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2e') {
                    agent {
                        docker {
                            //image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            image 'mcr.microsoft.com/playwright:v1.62.0-noble'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                        npm install serve
                        node_modules/.bin/serve -s build &
                        npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
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
                node_modules/.bin/netlify --version
                echo "Deploying to production. project id: $NETLIFY_PROJECT_ID"
                node_modules/.bin/netlify status
                node_modules/.bin/netlify deploy --dir=build --no-build --json > staging_output.json
                '''
                script {
                    env.STAGING_URL = sh(script:"node_modules/.bin/node-jq -r '.deploy_url' staging_output.json", returnStdout: true)
                }
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
                CI_ENVIRONMENT_URL = 'https://sprightly-faloodeh-638057.netlify.app/'
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

        stage('Approval') {
            steps {
                timeout(30) {
                //timeout(time: 1, unit: 'HOURS') {
                    input cancel: 'No', message: 'Read to deploy? ', ok: 'Yes i approve the deployment'
                }
            }
        }   

        // stage('Deploy prod') {
        //     agent {
        //         docker {
        //             image 'node:22-alpine'
        //             reuseNode true
        //         } 
        //     }
        //     steps {
        //         sh '''
        //         npm install netlify-cli
        //         node_modules/.bin/netlify --version
        //         echo "Deploying to production. project id: $NETLIFY_PROJECT_ID"
        //         node_modules/.bin/netlify status
        //         node_modules/.bin/netlify deploy --dir=build --prod --no-build
        //         '''
        //     }
        // }

        //stage('Prod E2e') {
        stage('Deploy prod') {
            agent {
                docker {
                //image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                image 'mcr.microsoft.com/playwright:v1.62.0-noble'
                reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'PROD_URL_NEED_TO_BE_SET'
            }
            steps {
                sh '''
                npm install netlify-cli
                node_modules/.bin/netlify --version
                echo "Deploying to production. project id: $NETLIFY_PROJECT_ID"
                node_modules/.bin/netlify deploy --dir=build --prod --no-build --json > prod_output.json
                CI_ENVIRONMENT_URL=${node_modules/.bin/node-jq -r '.deploy_url' prod_output.json}
                npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'PROD E2e Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }        
        }
    }
}
