pipeline {
    agent any

    stages {
        stage('provision') {
            steps {
                script {
                    sh('terraform apply --auto-approve')
                }
            }
        }
        
        stage('update') {
            steps {
                script {
                    sh('sudo python3 update_ansible_hosts.py')
                }
            }
        }

        stage('configure') {
            steps {
                script {
                    sh('ansible-playbook --private-key=/home/ricky/.aws/AWSEC2.pem -u ec2-user test.yml')
                }
            }
        }
    }
}