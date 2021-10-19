pipeline {
    agent any
    stages {
        stage("Compile and Run UniTest") {
            steps {
                sh "cp ~/env/hosts ./inventories/"
                sh "mvn clean compile test -X '-Dtest=!AutoCalcAppTest*'"
                echo "Code Compiled and Tested."                
            }
        }
        stage("Package") {
            steps {
                sh "mvn -X '-Dtest=!AutoCalcAppTest*' package"
                echo "Package completed"
            }
        }
        stage("Run Automated Tests") {
            steps {
                sh "docker stop bsafe-container || true"
                sh "docker rm bsafe-container || true"
                sh "docker rmi bsafe-test || true"
                sh "docker build -t bsafe-test ."
                sh "docker run -d --name bsafe-container -p 8082:8080 bsafe-test"
                sh "chmod 777 -R ./drivers/"
                sh "mvn '-DtestHost=localhost:8082' '-Dwebdriver.chrome.driver=/var/lib/jenkins/workspace/bsafe-app-server/drivers/chromedriver' test"
                echo "Automated Tests completed"
            }
        }
        stage("Docker build and Tag") {
            steps {
                sh "docker build -t ${JOB_NAME}:v1.${BUILD_NUMBER} ."
                sh "docker tag ${JOB_NAME}:v1.${BUILD_NUMBER} nandocandrade80/${JOB_NAME}:v1.${BUILD_NUMBER} "
                sh "docker tag ${JOB_NAME}:v1.${BUILD_NUMBER} nandocandrade80/${JOB_NAME}:latest "
                echo "Built and Taged completed"
            }
        }
        stage("Push container") {
            steps{
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                  sh "docker login -u=${USERNAME} -p=${PASSWORD} "
                  sh "docker push ${USERNAME}/${JOB_NAME}:v1.${BUILD_NUMBER}"
                  sh "docker push ${USERNAME}/${JOB_NAME}:latest"
                  sh "docker rmi ${JOB_NAME}:v1.${BUILD_NUMBER} ${USERNAME}/${JOB_NAME}:v1.${BUILD_NUMBER} ${USERNAME}/${JOB_NAME}:latest"
                }
                echo "Container pushed"
            }
        }
        stage("Docker Deploy") {
            steps{
                sh "ansible-playbook main.yml -i inventories/hosts --user jenkins --key-file ~/.ssh/bsafe.pem"
                echo "Deploy completed"
            }
        }
    }
}
