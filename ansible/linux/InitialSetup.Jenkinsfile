pipeline {
    agent {
        kubernetes {
            defaultContainer 'jnlp'
            yamlFile 'ansible/jenkins-pod.yaml'
        }
    }
    stages {
        stage('Playbook') {
            environment {
                ANSIBLE_HOST_KEY_CHECKING = 'False'
                INFISICAL_URL = credentials('infisical_url')
                UNIVERSAL_AUTH_MACHINE_IDENTITY_CLIENT_ID = credentials('INFISICAL_CLIENT_ID')
                UNIVERSAL_AUTH_MACHINE_IDENTITY_CLIENT_SECRET = credentials('INFISICAL_CLIENT_SECRET')
            }
            steps {
                container('ansible') {
                    withCredentials([sshUserPrivateKey(credentialsId: 'initial_setup_private_key', 
                        keyFileVariable: 'ANSIBLE_PRIVATE_KEY_FILE', usernameVariable: 'SSH_USER')]) {
                        sh 'ansible-playbook -i ansible/linux/inventory.ini ansible/linux/initial_setup.yml -u ${SSH_USER} --become'
                    }
                }
            }
        }
    }
}
