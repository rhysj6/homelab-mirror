pipeline {
    agent {
        kubernetes{ 
            defaultContainer 'jnlp'
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
                containers:
                - name: docker
                  image: docker:dind
                  securityContext:
                    privileged: true
                  volumeMounts:
                  - mountPath: /var/lib/docker
                    name: docker-graph-storage
                - name: python
                  image: python:3.21
                  command:
                    - sleep
                    - infinity
                volumes:
                - name: docker-graph-storage
                  emptyDir: {}
            """
        }
    }
    parameters {
        string(name: 'tag', defaultValue: 'latest', description: 'Image tag to use for the Docker image.')
    }

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub')
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    if (env.GIT_TAG) {
                        mutableTag = 'latest'
                        immutableTag = env.GIT_TAG
                    }
                }
                container('docker') {
                    sh 'docker login -u $DOCKER_CREDENTIALS_USR -p $DOCKER_CREDENTIALS_PSW'
                }
                container('python') {
                    sh 'pip install ansible-builder'
                }
            }
        }

        stage ('Ansible build') {
            steps {
                container('python') {
                    sh 'ansible-builder create -f ansible/execution-environment.yml'
                }
            }
        }
        stage('Docker build') {
            steps {
                container('docker') {
                    sh "docker build -t ansible-agent ansible/context"
                }
            }
        }
        stage('Push Docker images') {
            steps {
                container('docker') {
                    sh "docker image tag ansible-agent rhysj6/ansible-agent:${params.tag}"

                    sh "docker push rhysj6/ansible-agent:${params.tag}"
                }
            }
        }
    }
}