pipeline {
    agent any

    stages {
        stage('checkout') {
            steps {
                checkout scm
            }
        }

        stage('provision') {
            steps {
                withCredentials([[
                    class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWSEC2',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                 ]]) { 
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform plan'
                        sh 'terraform apply --auto-approve'
                    }
                }
            }
        }
        
        stage('update') {
            steps {
                dir('scripts') {
                    sh 'sudo python3 update_ansible_hosts.py'
                }
            }
        }

        stage('configure') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook --private-key=/home/ricky/.aws/AWSEC2.pem -u ec2-user test.yml'
                }
            }
        }
    }
}