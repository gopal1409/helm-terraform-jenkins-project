pipeline{
    agent any 

    environment {
        NEXUS_DOCKER_URL="35.209.45.241:8085"
        NEXUS_URL="35.209.45.241:8081"
        IMAGE_NAME="simple-app"
        IMAGE_TAG="${env.BUILD_ID}"
        VM_IP="0.0.0.0"
    }

    stages{
        stage('mvn build') {
            steps {
                dir("Api1"){
                    sh 'mvn -B -DskipTest clean package'
                }
            }
        }
        stage('mvn test') {
            steps {
                dir("Api1"){
                    sh 'mvn test'
                    junit 'target/surefire-reports/*.xml'
                    sh 'mvn checkstyle:checkstyle'
                    recordIssues(tools: [checkStyle(pattern: '**/checkstyle-result.xml')])
                    jacoco()
                }
            }
        }
        stage('sonar') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                  	input(id: "sonar", message: "SonarQube", ok: 'OK')
                }
                dir("Api1"){
                    sh 'mvn clean verify sonar:sonar \
                            -Dsonar.projectKey=kislaya \
                            -Dsonar.host.url=http://35.206.100.225:9000 \
                            -Dsonar.login="${sonar_cred}"' 
                }    
            }
        }
        stage('Upload Jar to Nexus') {
            steps {
                script {
                    dir("Api1"){
                        pom = readMavenPom file: "pom.xml";
                        filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                        echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                        artifactPath = filesByGlob[0].path;
                
                        nexusArtifactUploader artifacts: [[artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging]], credentialsId: 'nexus', groupId: pom.artifactId, nexusUrl: "${NEXUS_URL}", nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: pom.version  
                    }
                }
            }
        }
        stage('Docker build') {
            steps {
                script{
                    dir("Api1"){
                        sh "mvn spring-boot:build-image -Dspring-boot.build-image.imageName=${NEXUS_DOCKER_URL}/${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Docker push to Nexus') {
            steps {
                script{
                    dir("Api1"){
                        withDockerRegistry(credentialsId: 'nexus', url: "http://${NEXUS_DOCKER_URL}") {
                            sh "docker tag simple-app ${NEXUS_DOCKER_URL}/${IMAGE_NAME}:${IMAGE_TAG}"
                            sh "docker push ${NEXUS_DOCKER_URL}/${IMAGE_NAME}:${IMAGE_TAG}"
                        }
                    }
                }
            }
        }
        
        stage("Install Tomcat"){
            steps{
                script{
                    ansiblePlaybook credentialsId: 'jenkins-chat-app', disableHostKeyChecking: true, inventory: 'ansible/dev.inv', playbook: 'ansible/install_tomcat.yaml'
                }
            }
        }
        stage("Deploy war file"){
            steps{
                script{
                    ansiblePlaybook credentialsId: 'jenkins-chat-app', disableHostKeyChecking: true, inventory: 'ansible/dev.inv', playbook: 'ansible/deploy_war_tomcat.yaml', vaultCredentialsId: 'ansible-vault'
                }
            }
        }
        stage("Install Docker"){
            steps{
                script{
                    ansiblePlaybook credentialsId: 'jenkins-chat-app', disableHostKeyChecking: true, inventory: 'ansible/dev.inv', playbook: 'ansible/install_docker.yaml'
                }
            }
        }
        stage("Deploy docker image"){
            steps{
                script{
                    timeout(time: 5, unit: 'MINUTES') {
                		input(id: "private-repo", message: "private repo", ok: 'ok')
                    }
                    ansiblePlaybook credentialsId: 'jenkins-chat-app', extras: '--extra-vars="image_tag=${IMAGE_TAG}"', inventory: 'ansible/dev.inv', playbook: 'ansible/run_docker.yaml', vaultCredentialsId: 'ansible-vault'
                }
            }
        }
        stage("Create Server and comp."){
            steps{
                dir("terraform/kind-k8s"){
                    script {
                        withCredentials([string(credentialsId: 'vm-ssh-password', variable: 'vm_passowrd')]) {
                            sh 'terraform init'
                            sh 'terraform plan -var="password=${vm_passowrd}"'
                            sh 'terraform apply -var="password=${vm_passowrd}" --auto-approve'
                            VM_IP = sh(script:'terraform output public_ip_address', returnStdout: true).trim()
                        }
                    }
                }
            }
        }
        stage("Run helm in k8s"){
            steps{
                dir("terraform/kind-k8s"){
                    script{
                        timeout(time: 5, unit: 'MINUTES') {
                  			input(id: "private-repo", message: "private repo in kind", ok: 'ok')
                        }
                        withCredentials([string(credentialsId: 'vm-ssh-password', variable: 'vm_passowrd')]) {
                            echo "$VM_IP"
                            sh "sshpass -p ${vm_passowrd} ssh -o StrictHostKeyChecking=no kislaya@${VM_IP} 'sudo helm upgrade --set image.tag=${IMAGE_TAG} simple-app simple-app/'"
                        }
                    }
                }
            }
        }
        stage("Create AKS and comp."){
            steps{
                dir("terraform/aks-k8s"){
                    script {            
                        sh 'terraform init'
                        sh 'terraform plan'
                        sh 'terraform apply --auto-approve'
                    }
                }
            }
        }
        stage("Helm deploy simple-app"){
            steps{
                dir("terraform/aks-k8s/helm"){
                    script {   
                        sh 'az aks get-credentials --resource-group capstone-aks-rg --name capstone-aks-aks'         
                        sh "helm upgrade --set image.tag=${IMAGE_TAG} simple-app simple-app/"
                    }
                }
            }
        }
    }
    post{
        always{
            deleteDir()
            sh "docker rmi ${NEXUS_DOCKER_URL}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
    }
}
