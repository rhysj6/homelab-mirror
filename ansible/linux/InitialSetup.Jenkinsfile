pipeline {
    agent {
        kubernetes {
            defaultContainer 'jnlp'
            yamlFile 'ansible/jenkins-pod.yaml'
        }
    }
    stages {
        stage('Initalisation'){
            steps {
                dir('private'){
                    checkout scmGit(branches: [[name: 'main']],
                        userRemoteConfigs: [[url: 'https://github.com/rhysj6/homelab-private.git', credentialsId: 'github']])
                }
            }
        }
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
                        sh 'ansible-playbook -i private/ansible/inventory.yml ansible/linux/playbooks/initial_setup.yml --become'
                    }
                }
            }
        }
    }
}
