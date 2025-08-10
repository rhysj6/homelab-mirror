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
                    sh 'ansible-galaxy install -r ansible/linux/requirements.yml'
                    ansiblePlaybook(
                        playbook: 'ansible/linux/initial_setup.yml',
                        inventory: 'ansible/linux/inventory.ini',
                        credentialsId: 'initial_setup_private_key'
                    )
                }
            }
        }
    }
}
