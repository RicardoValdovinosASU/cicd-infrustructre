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
                dir('terraform') {
                    sh '/usr/bin/terraform init'
                    sh '/usr/bin/terraform plan'
                    sh '/usr/bin/terraform apply --auto-approve'
                }
            }
        }
        
        stage('update') {
            steps {
                dir('scripts') {
                    sh('sudo python3 update_ansible_hosts.py')
                }
            }
        }

        stage('configure') {
            steps {
                dir('ansible') {
                    sh('ansible-playbook --private-key=/home/ricky/.aws/AWSEC2.pem -u ec2-user test.yml')
                }
            }
        }
    }
}