pipeline {
    agent {
	label 'Dev'
    }
    parameters {
        booleanParam(
            name: 'FORCE_DEPLOY',
            defaultValue: false,
            description: 'Force deployment even if no service changes detected'
        )
    }

    environment {
        NO_CHANGES = "false"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code"
                checkout scm
            }
        }
        stage('Detect Changes') {
            steps {
                echo "Detecting changed services"

                sh '''
                  chmod +x detect-changes.sh
                  ./detect-changes.sh
                '''

                script {
                    if (!fileExists('changed-services.txt') ||
                        readFile('changed-services.txt').trim() == "") {

                        if (params.FORCE_DEPLOY) {
                            echo "No code changes, but FORCE_DEPLOY enabled"
                            env.NO_CHANGES = "false"
                        } else {
                            echo "No services changed"
                            env.NO_CHANGES = "true"
                            currentBuild.result = 'SUCCESS'
                        }

                    } else {
                        env.NO_CHANGES = "false"
                    }
                }
            }
        }
        stage('Build Changed Services') {
            when {
                expression {
                    env.NO_CHANGES != "true" && !params.FORCE_DEPLOY
                }
            }
            steps {
                script {
                    def changes = readFile('changed-services.txt').trim()

                    if (changes == "") {
                        echo "Nothing to build"
                        return
                    }

                    changes.split('\n').each { line ->
                        def parts = line.trim().split(/\s+/)

                        if (parts.length < 2) {
                            echo "Skipping invalid build entry: '${line}'"
                            return
                        }

                        def serviceDir = parts[0]
                        def imageName  = parts[1]

                        echo "🛠 Building ${serviceDir} → ${imageName}"

                        dir(serviceDir) {
                            if (fileExists('pom.xml')) {
                                sh 'mvn clean package -DskipTests'
                            }
                            sh "docker build -t ${imageName} ."
                        }
                    }
                }
            }
        }
        stage('Deploy') {
            when {
                expression { env.NO_CHANGES != "true" }
            }
            steps {
                script {
                    if (params.FORCE_DEPLOY) {
                        echo "♻ FORCE_DEPLOY: restarting ALL services"
                        sh '''
                          docker compose down
                          docker compose up -d
                        '''
                        return
                    }
                    def changes = readFile('changed-services.txt').trim()

                    if (changes == "") {
                        echo "Nothing to deploy"
                        return
                    }

                    changes.split('\n').each { line ->
                        def parts = line.trim().split(/\s+/)

                        if (parts.length < 2) {
                            echo "Skipping invalid deploy entry: '${line}'"
                            return
                        }

                        def serviceDir = parts[0]
                        def imageName  = parts[1]
                        def serviceKey = serviceDir
                                            .replace('-service','')
                                            .toUpperCase()

                        def serviceName = serviceKey.toLowerCase()

                        echo "Deploying ${serviceName} with image ${imageName}"

                        sh """
				 sed -i 's|^${serviceKey}_IMAGE=.*|${serviceKey}_IMAGE=${imageName}|' .env
                  		docker compose up -d --no-deps --force-recreate ${serviceName}
                        """
                    }
                }
            }
        }
    }
}
