pipeline {
    agent any

    environment {
        // Define the correct Credential ID once to prevent future typos.
        AWS_CRED_ID = 'aws-credentials-Khatri' 
        // Note: I've assumed the correct ID is 'aws-credentials-Khatri'
    }

    parameters {
            booleanParam(name: 'PLAN_TERRAFORM', defaultValue: false, description: 'Check to plan Terraform changes')
            booleanParam(name: 'APPLY_TERRAFORM', defaultValue: false, description: 'Check to apply Terraform changes')
            // CORRECTED: Fixed the typo in the description here
            booleanParam(name: 'DESTROY_TERRAFORM', defaultValue: false, description: 'Check to destroy Terraform infrastructure')
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Good practice to ensure a clean workspace
                deleteDir()

                // Clone the Git repository
                git branch: 'main',
                    url: 'https://github.com/khxtrikk/devops-project-1.git'

                sh "ls -lart"
            }
        }

        stage('Terraform Init') {
            steps {
                // Using the defined environment variable
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CRED_ID]]) {
                    dir('infra') {
                        sh 'echo "=================Terraform Init=================="'
                        sh 'terraform init -reconfigure'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.PLAN_TERRAFORM) {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CRED_ID]]) {
                            dir('infra') {
                                sh 'echo "=================Terraform Plan=================="'
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform show tfplan'
                            }
                        }
                    } else {
                        echo "Skipping Terraform Plan - set PLAN_TERRAFORM=true to run"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    if (params.APPLY_TERRAFORM) {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CRED_ID]]) {
                            dir('infra') {
                                sh 'echo "=================Terraform Apply=================="'
                                sh 'terraform apply -auto-approve tfplan || terraform apply -auto-approve'
                            }
                        }
                    } else {
                        echo "Skipping Terraform Apply - set APPLY_TERRAFORM=true to run"
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    if (params.DESTROY_TERRAFORM) {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CRED_ID]]) {
                            dir('infra') {
                                sh 'echo "=================Terraform Destroy=================="'
                                sh 'terraform destroy -auto-approve'
                            }
                        }
                    }
                }
            }
        }
    }
}