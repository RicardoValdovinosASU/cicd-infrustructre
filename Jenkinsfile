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
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'db293874-9c24-432d-81a7-3671751fa1bf', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform plan'
                        sh 'terraform apply --auto-approve | tee output'
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
                    ansiblePlaybook credentialsId: 'a114dae9-c1ef-42a0-ac97-b072b4fcc165', disableHostKeyChecking: true, playbook: 'test.yml'
                    // sh 'ansible-playbook -vvvv --private-key=/home/ricky/.aws/AWSEC2.pem -u ec2-user test.yml'
                }
            }
        }
    }
}