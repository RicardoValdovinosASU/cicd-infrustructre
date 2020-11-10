pipeline {
    agent any

    stages {
        stage('provision') {
            steps {
                dir('terraform') {
                    script {
                        sh('terraform init')
                        sh('terraform plan')
                        sh('terraform apply --auto-approve')
                    }
                }
            }
        }
        
        stage('update') {
            steps {
                dir('scripts') {
                    script {
                        sh('sudo python3 update_ansible_hosts.py')
                    }
                }
            }
        }

        stage('configure') {
            steps {
                dir('ansible') {
                    script {
                        sh('ansible-playbook --private-key=/home/ricky/.aws/AWSEC2.pem -u ec2-user test.yml')
                    }
                }
            }
        }
    }
}