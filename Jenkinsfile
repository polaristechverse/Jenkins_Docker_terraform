pipeline {
    agent {
        label 'Dev'
    }
    parameters {
        choice(name: 'PACKER_ACTION',  
        choices: ['NOAPPLY','APPLY'], 
        description: 'Select packer action')
        choice(name: 'TERRAFORM_ACTION',  
        choices: ['PLAN','APPLY','DESTROY'], 
        description: 'Select packer action')
    }
   
       
stages {
    stage('scm checkout'){
        steps{
            sh ' echo " accessing the github repo" '
            checkout scm
        }
    }
    stage('packer terraform checking'){
        steps{
            sh 'packer version'
            sh 'terraform version'
        }
    }
    stage('packer_validating_build'){
         when {
                expression { params.PACKER_ACTION == 'APPLY' }
            }
        steps{
            sh 'packer plugins install github.com/hashicorp/amazon'
            sh 'packer validate --var-file packer-vars.json packer.json'
            sh 'packer build --var-file packer-vars.json packer.json'
            
        }
    }
    stage('AmiID'){
        steps{
            sh'echo "fetching ami id"'
            script {
                def amiID = sh(
                    script: '''cat manifest.json | grep artifact_id |tr -d '",'| cut -d ':' -f3''',
                    returnStdout: true
                    ).trim()
                    echo "AMI ID created:${amiID}"
                    env.AMI_ID = amiID
            }
        }
    }
    stage('Terraform_Plan'){
         when {
                expression { params.TERRAFORM_ACTION == 'PLAN' }
            }
            steps{
                sh """
                sed -i 's|^ami *=.*|ami = "${env.AMI_ID}"|' terraform.tfvars
                """
                sh 'terraform init'
                sh 'terraform validate'
                sh 'terraform plan'
            }
    }
    stage('Terrafor_Apply'){
         when {
                expression { params.TERRAFORM_ACTION == 'APPLY' }
            }
            steps{
                sh """
                sed -i 's|^ami *=.*|ami = "${env.AMI_ID}"|' terraform.tfvars
                """
                sh 'terraform init'
                sh 'terraform validate'
                sh 'terraform apply --auto-approve'
            }
    }
        stage('Terrafor_Destory'){
         when {
                expression { params.TERRAFORM_ACTION == 'DESTROY' }
            }
            steps{
                sh """
                sed -i 's|^ami *=.*|ami = "${env.AMI_ID}"|' terraform.tfvars
                """
                sh 'terraform init'
                sh 'terraform destroy --auto-approve'
            }
    }
}
}
