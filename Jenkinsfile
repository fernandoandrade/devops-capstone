pipeline {
    agent any
    tools {
        maven 'mvn'
    }
    stages {
        stage('Compile and Run UniTest') {
            steps {
                sh 'mvn clean compile'
                echo 'Code Compiled and Tested.'                
            }
        }
        stage('Package') {
            steps {
                sh 'mvn "-Dtest=!AutoCalcAppTest*" package'
                echo 'Package completed'             
            }
        }
        stage('Run Automated Tests') {
            steps {
                sh 'docker stop bsafe-container'
                sh 'docker rm bsafe-container'
                sh 'docker rmi bsafe-test'
                sh 'docker build -t bsafe-test .'
                sh 'docker run -d --name bsafe-container -p 8082:8080 bsafe-test'
                sh 'mvn "-DtestHost=localhost:8082" "-Dwebdriver.chrome.driver=C:\\Users\\fcata\\OneDrive\\Documentos\\devops\\devops-capstone\\drivers\\chromedriver.exe" test '
                echo 'Automated Tests completed'
            }
        }
    }
}
