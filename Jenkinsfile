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
                sh "docker stop bsafe-container"
                sh "docker rm bsafe-container"
                sh "docker rmi bsafe-test"
                sh "docker build -t bsafe-test ."
                sh "docker run -d --name bsafe-container -p 8082:8080 bsafe-test"
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
                withDockerRegistry([ credentialsId: "dockerHub", url: "" ]) {
                  sh "docker push nandocandrade80/${JOB_NAME}:v1.${BUILD_NUMBER}"
                  sh "docker push nandocandrade80/${JOB_NAME}:latest"
                  sh "docker rmi ${JOB_NAME}:v1.${BUILD_NUMBER} nandocandrade80/${JOB_NAME}:v1.${BUILD_NUMBER} nandocandrade80/${JOB_NAME}:latest"
                }
                echo "Container pushed"
            }
        }
        stage("Docker Deploy") {
            steps{
                sh "ansible-playbook main.yml -i inventories/dev/hosts --user jenkins --key-file ~/.ssh/bsafe.pem"
                echo "Deploy completed"
            }
        }
    }
}
