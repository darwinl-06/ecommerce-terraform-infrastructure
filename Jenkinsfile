pipeline {
    agent any

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        TF_VAR_project_id = 'proyecto-final-ingesoftv'
        TF_LOG = 'INFO'
        PATH = "C:\\Program Files (x86)\\Google\\Cloud SDK\\google-cloud-sdk\\bin;${env.PATH}"
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

        stage('Approve Deploy') {
            when {
                anyOf {
                    branch 'stage'
                    branch 'master'
                    branch 'dev'
                }
            }
            steps {
                emailext(
                    to: '$DEFAULT_RECIPIENTS',
                    subject: "Action Required: Approval Needed for Deploy of Infraestructure #${env.BUILD_NUMBER}",
                    body: """\
                    The build #${env.BUILD_NUMBER} for branch *${env.BRANCH_NAME}* has completed and is pending approval for deployment.
                    Please review the changes and approve or abort
                    You can access the build details here:
                    ${env.BUILD_URL}
                    """
                )
                input message: '¿Aplicar cambios en Staging?', ok: 'Aplicar'
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

        stage('Authenticate to GCP') {
            steps {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    bat """
                    echo "🔐 Activando cuenta de servicio..."
                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                    gcloud config set project $TF_VAR_project_id
                    """
                }
            }
        }

        stage('Get GKE Credentials') {
            steps {
                script {
                    def clusterName = "ecommerce-cluster-${env.TF_ENVIRONMENT}"
                    def zone = env.TF_ENVIRONMENT == 'prod' ? 'us-central1' : 'us-central1-a'
                    
                    bat """
                    echo 🔐 Obteniendo credenciales del cluster GKE...
                    gcloud container clusters get-credentials ${clusterName} --zone ${zone} --project ${env.TF_VAR_project_id}
                    """
                }
            }
        }

        stage('Ensure Namespace') {
            steps {
                bat "kubectl get namespace monitoring || kubectl create namespace monitoring"
                bat "kubectl get namespace logging || kubectl create namespace logging"
            }
        }

        stage('Deploy Observability Stack') {
            when { branch 'master' }
            steps {
                bat '''
                    echo "📊 Deploying Prometheus and Grafana with ..."

                    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                    helm repo update

                    helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack ^
                    --namespace monitoring --create-namespace ^
                    -f modules/monitoring/values.yaml
                 
                    echo "✅ Observability stack deployed successfully!"
                '''
            }
        }

        stage('Deploy ELK Stack') {
            when { branch 'master' }
            steps {
                bat '''
                    echo "📊 Deploying ELK Stack (Elasticsearch, Logstash, Kibana) and Filebeat..."

                    helm repo add elastic https://helm.elastic.co
                    helm repo update

                    echo "📦 Deploying Elasticsearch..."
                    helm upgrade --install elasticsearch elastic/elasticsearch ^
                    --namespace logging --create-namespace ^
                    -f modules/monitoring/elasticsearch-values.yaml

                    echo "⏳ Waiting for Elasticsearch to be ready..."
                    kubectl wait --for=condition=Ready pod -l app=elasticsearch-master ^
                    --namespace logging --timeout=600s

                    echo "📦 Deploying Logstash..."
                    helm upgrade --install logstash elastic/logstash ^
                    --namespace logging ^
                    -f modules/monitoring/logstash-values.yaml

                    echo "📦 Deploying Kibana..."
                    helm upgrade --install kibana elastic/kibana ^
                    --namespace logging ^
                    -f modules/monitoring/kibana-values.yaml

                    echo "📦 Deploying Filebeat..."
                    helm upgrade --install filebeat elastic/filebeat ^
                    --namespace logging ^
                    -f modules/monitoring/filebeat-values.yaml

                    echo "✅ ELK Stack and Filebeat deployed successfully!"
                '''
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
