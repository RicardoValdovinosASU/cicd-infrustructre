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
                    sh 'terraform -input=false init'
                    sh 'terraform -input=false plan'
                    sh 'terraform apply -input=false --auto-approve'
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