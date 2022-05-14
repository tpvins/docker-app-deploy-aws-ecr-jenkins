pipeline {
    agent any
    environment {
        DEPLOYMENT_REPO_CRED_ID = 'MY_GIT_RSA_ID'
        AWS_CRED_ID = 'MY_AWS_CREDS_ID'
        AWS_ACCOUNT_NUMBER = credentials("AWS_ACCOUNT_NUMBER")
        AWS_DEFAULT_REGION = credentials("AWS_DEFAULT_REGION")
        AWS_ACCESS_KEY_ID = credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY = credentials("AWS_SECRET_ACCESS_KEY")
        IMAGE_REPO_NAME = "sample"
        AWS_ECR_URI = "https://${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        AWS_ECR_CREDS_URI = "ecr:${AWS_DEFAULT_REGION}:${AWS_CRED_ID}"
        BUILD_NUMBER = 'latest'
        ABSOLUTE_LATEST_BUILD_IMAGE_NAME = "${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${BUILD_NUMBER}"
        DEPLOYMENT_REPO = credentials('DEPLOYMENT_REPO')
        DEPLOYMENT_BRANCH = credentials('DEPLOYMENT_BRANCH')
        LATEST_BUILD_IMAGE = ''
        DEPLOYEMNT_SERVER_CREDENTIAL_ID = 'deployment_cred_id'
        DEPLOYEMENT_HOST = credentials('DEPLOYEMENT_HOST')
        DEPLOYEMENT_USER = credentials('DEPLOYEMENT_USER')
        AWS_REMOTE_ENVIROMENT = "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} ; export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} ; export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} ;"
    }
    stages {
        stage('Cloning deployement repository') {
            steps {
                git credentialsId: DEPLOYMENT_REPO_CRED_ID, 
                    url: DEPLOYMENT_REPO, 
                    branch: DEPLOYMENT_BRANCH
            }
        }
        stage('Build image from deployement repository') {
            steps{
                script {
                    LATEST_BUILD_IMAGE = docker.build ABSOLUTE_LATEST_BUILD_IMAGE_NAME
                }
            }
        }

        stage('Docker login on deployment server') {
            steps {
                script {
                    sshagent([DEPLOYEMNT_SERVER_CREDENTIAL_ID]) {
                        TOKEN = sh(
                            script: "ssh -o StrictHostKeyChecking=no ${DEPLOYEMENT_USER}@${DEPLOYEMENT_HOST}  -tt ' ${AWS_REMOTE_ENVIROMENT} aws ecr get-login-password --region ${AWS_DEFAULT_REGION}'",
                            encoding: "UTF-8",
                            returnStdout: true
                            ).trim()
                        sh "ssh -o StrictHostKeyChecking=no ${DEPLOYEMENT_USER}@${DEPLOYEMENT_HOST}  -tt 'sudo docker login --username AWS --password ${TOKEN} ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com'"
                    }
                }
            }
        }
        stage('Pull latest image in to deployment server') {
            steps {
                script{
                    sshagent([DEPLOYEMNT_SERVER_CREDENTIAL_ID]) {
                        if (sh(script: "ssh -o StrictHostKeyChecking=no ${DEPLOYEMENT_USER}@${DEPLOYEMENT_HOST}  -tt 'sudo docker pull ${ABSOLUTE_LATEST_BUILD_IMAGE_NAME}'",
                            returnStatus: true
                        ).equals(0)) {
                            echo 'Pulled latest image in deployment server'
                        }else {
                            currentBuild.result = "FAILURE"
                            throw new Exception("Failed to pull latest image in to the deployment server")
                        }
                    }
                }
            }
        }

        stage('Deploy latest image') {
            steps {
                script{
                    sshagent([DEPLOYEMNT_SERVER_CREDENTIAL_ID]) {
                        if (sh(script: "ssh -o StrictHostKeyChecking=no ${DEPLOYEMENT_USER}@${DEPLOYEMENT_HOST}  -tt 'sudo docker run -p 9000:8080 -d ${ABSOLUTE_LATEST_BUILD_IMAGE_NAME}'",
                            returnStatus: true
                        ).equals(0)) {
                            echo 'Deployment successful'
                        }else {
                            currentBuild.result = "FAILURE"
                            throw new Exception("Failed deployment")
                        }
                    }
                }
            }
        }
    }
}