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
                INFISICAL = credentials('infisical')
            }
            steps {
                container('ansible') {
                    ansiblePlaybook(
                        playbook: 'ansible/linux/initial_setup.yml',
                        inventory: 'ansible/linux/inventory.ini',
                        credentialsId: 'initial_setup_private_key',
                        become: true,
                        extraVars: [
                            UNIVERSAL_AUTH_MACHINE_IDENTITY_CLIENT_ID: env.INFISICAL_USR,
                            UNIVERSAL_AUTH_MACHINE_IDENTITY_CLIENT_SECRET: env.INFISICAL_PSW,
                            INFISICAL_URL: env.INFISICAL_URL,
                        ]
                    )
                }
            }
        }
    }
}
