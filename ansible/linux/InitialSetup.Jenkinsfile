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
                ANSIBLE_USER = credentials('ansible_user')
                ANSIBLE_USER_PUBLIC_SSH_KEY = credentials('ansible_user_public_ssh_key')
                PROMETHEUS_IP = credentials('prometheus_ip')
                LOKI_URL = credentials('loki_url')
                LOKI_TENANT = credentials('loki_tenant')
                LOKI_PASSWORD = credentials('loki_password')
                INITIAL_USER = credentials('initial_user')

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

                            automation_user: env.ANSIBLE_USER_USR,
                            automation_user_password: env.ANSIBLE_USER_PSW,
                            automation_user_public_ssh_key: env.ANSIBLE_USER_PUBLIC_SSH_KEY,
                            initial_user: env.INITIAL_USER,
                            prometheus_ip: env.PROMETHEUS_IP,
                            loki_url: env.LOKI_URL,
                            loki_tenant: env.LOKI_TENANT,
                            loki_password: env.LOKI_PASSWORD
                        ]
                    )
                }
            }
        }
    }
}
