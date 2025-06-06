pipeline {
    agent any

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        TF_VAR_project_id = 'proyecto-final-ingesoftv'
        TF_LOG = 'INFO'
    }

    stages {

        stage('Setup') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'master') {
                        env.TF_ENVIRONMENT = 'prod'
                    } else if (env.BRANCH_NAME == 'stage') {
                        env.TF_ENVIRONMENT = 'staging'
                    } else {
                        env.TF_ENVIRONMENT = 'dev'
                    }
                    
                    echo "🌍 Branch: ${env.BRANCH_NAME}"
                    echo "🏗️ Environment: ${env.TF_ENVIRONMENT}"
                }
            }
        }

        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/darwinl-06/ecommerce-terraform-infrastructure.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("environments/${env.TF_ENVIRONMENT}") {
                    bat '''
                    echo 🔧 Inicializando Terraform...
                    terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("environments/${env.TF_ENVIRONMENT}") {
                    bat '''
                    echo 📋 Generando plan...
                    terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Approve Staging') {
            when { branch 'stage' }
            steps {
                input message: '¿Aplicar cambios en Staging?', ok: 'Aplicar'
            }
        }

        stage('Approve Production') {
            when { branch 'master' }
            steps {
                input message: '¿Aplicar cambios en Producción?', ok: 'Aplicar'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("environments/${env.TF_ENVIRONMENT}") {
                    bat '''
                    echo 🚀 Aplicando cambios...
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Show Outputs') {
            steps {
                dir("environments/${env.TF_ENVIRONMENT}") {
                    bat '''
                    echo 📊 Outputs de infraestructura:
                    terraform output
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completado exitosamente en ${env.TF_ENVIRONMENT}"
        }

        failure {
            echo "❌ Pipeline falló en ${env.TF_ENVIRONMENT}"
        }

        always {
            dir("environments/${env.TF_ENVIRONMENT}") {
                bat 'if exist tfplan del tfplan'
            }
        }
    }
}
