# cicd-practica-yilisramirez

This practice has the purpose to provide storage for dev and production environment, which are named `acme-storage-dev-kc-storage` and `acme-storage-prod-kc-storage`. This will be deployed with AWS s3 resource, using terraform and Jenkins pipeline in an automated way.

# Prerequisites
- AWS account
- Install Terraform
- AWS cli
- IAM user
- GitHub account
- Jenkins
- Jenkins plugins --> `Folders` `build timeout` `timestamper` `pipeline` `pipeline: stage view` `Git` `SSH build agents` `SSH Agent Plugin` `Docker` `Job DSL`
- Docker
- Docker compose

# Requirements
1. As first step we will be creating an IAM user to use terraform.

   Open the AWS console and at the IAM dashboard, click on <b>User -> Add user</b>. Enter a username and then select <b>Access key - Programmatic access</b>.
   
   Now click on <b>Attach existing policies directly</b> and as policy we select <b>AdministratorAccess</b>. Click on create user option to deploy the credentials with the <b>Access key ID</b> and <b>Secret access key</b>
   
   Once installed Terraform and AWS CLI, we can set the AWS credentials as shown below: 
   
   ```
   $ aws configure
   [default]
   aws_access_key_id =
   aws_secret_access_key =
   region =
   output =
   ```

    Note these credentials are stored by default in the directory `~/.aws/credentials` and `~/.aws/config`
    
    After the environment has been configured, we defined the corresponding terraform files to create an AWS s3 bucket as Infraestructure as code.
    
    <b>main.tf</b>
      ```bash
      terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 4.9.0"
        }
      }
        backend "s3" {
        bucket  = "acme-storage-dev-kc-storage"
        key     = "infra_dev/terraform.tfstate"
        region  = "eu-west-1"
        encrypt = true
      }
    }

    provider "aws" {
      region                   = var.aws_region
      shared_config_files = [ "~/.aws/config" ]
      shared_credentials_files = ["~/.aws/credentials"]
    }

    resource "aws_s3_bucket" "storage" {
      bucket = "${var.s3_bucket_name}-storage"

      tags = {
        Name        = "${var.s3_bucket_name}-storage"
        Environment = "ACME storage dev"
      }
    }
   ```
    <b>variable.tf</b>
    ```
    variable "aws_region" {
      default = "eu-west-1"
    }

    variable "s3_bucket_name" {
      type    = string
      default = "acme-storage-dev-kc"
      ```
    Deploy terraform code to install the AWS s3 bucket
    . Run <b>terraform init</b> to initialize the environment
    . Run <b>terraform plan</b> to see the infraestructure that will be created
    . Run <b>terraform apply</b> to deploy the resources that will be created
    
     As best practice we have created a <b>s3 bucket backend</b> to store the state file remotely. This adds increased security, and also allows collaboration among        team members. 
    
    ![files tree](https://user-images.githubusercontent.com/39458920/166108886-09da98f0-ba37-4b1d-a71b-dd7b27cd883e.JPG)
    
    ```
    aws s3 ls s3://acme-storage-dev-kc-storage --recursive                                                
    2022-04-30 09:10:42       2262 infra_dev/terraform.tfstate
    ```
    Verifying the s3 bucket has been created
    ![aws s3](https://user-images.githubusercontent.com/39458920/166111697-2cd08f54-7a11-4b84-a9a3-c87c7ca7be9f.JPG)
    
    Adittionaly, we create the makefile so developers can test it in local environment.
    
    ```
    all: init plan format apply clean

    init:
      @echo init step
      cd infra && terraform init -backend-config='key=stage_dev/terraform.tfstate'

    plan:
      @echo plan step
      cd infra && terraform plan

    format:
      @echo format step
      cd infra && terraform fmt

    apply:
      @echo apply step
      cd infra && terraform apply -auto-approve

    clean:
      @echo clean step
      cd infra && rm -rf .terraform
      ```
      
      Once we verified our code terraform has deployed the s3 bucket properly, we proceed to create the Jenkins pipeline, so we need to configure our instance by             installing Docker, docker compose and the required plugins to run the pipeline as build agent.
      
      We have installed Jenkins master from a <b>docker-compose file</b>, which contains the jenkins image and the necessary volumes to run it.
      
      We run the command `docker compose up` to initialize Jenkins. Note that a jenkins_home folder is needed to store configuration there.
      beaware that a credential will be displayed in the output code, once it starts to run.
      
      That's the credential what we should introduce to log in `localhost:8080`
      
      ![jenkins](https://user-images.githubusercontent.com/39458920/166112881-46a85b7d-f0c5-4387-a780-2efcfbac24ce.JPG)
      
      Now we can build our project as `Freestyle project`. For this we need the Job DSL plugin has been already installed.
      
      At the build section, we introduce the DSL script to create two separate pipelines.
      
      ```
          pipelineJob('Infra') {
        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url("https://github.com/KeepCodingCloudDevops5/cicd-practica-yilisramirez.git")
                        }
                        branches("main")
                        scriptPath('Jenkinsfile.terraform')
                    }
                }
            }
        }
    }

    pipelineJob('Storage') {
        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url("https://github.com/KeepCodingCloudDevops5/cicd-practica-yilisramirez.git")
                        }
                        branches("main")
                        scriptPath('Jenkinsfile.storage')
                    }
                }
            }
        }
    }
    ```
    We proceed to build it and double check the pipelines have been created.
    
    ![build](https://user-images.githubusercontent.com/39458920/166113312-7ae0126c-59dd-48f1-8a47-27152221af30.JPG)
    
    To run pipelines as build agents using Docker, we need to install the Docker plugin and configure the Docker remote API in order for Jenkins master connects to the docker daemon using REST  APIs. So we need to enable the remote API.
    
    We open the docker service file `/lib/systemd/system/docker.service` edit the `ExecStart` line and replace it with this following line:
    
    `ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock`
    
    We save it and restart the docker daemon as follows:
    ```
    sudo systemctl daemon-reload
    sudo service docker restart
    ```
    We check the docker remote API has been deployed.
    
    ![docker api](https://user-images.githubusercontent.com/39458920/166113789-3f9708bd-37b5-43fd-afcb-d1ea76796679.JPG)

    Check the connection towards our docker IP
    
    ![test connection](https://user-images.githubusercontent.com/39458920/166113985-a9aadc55-0ae2-4e24-aef7-aafff4be1a20.JPG)
    
    We create the docker agent with the terraform image previously dockerized, specify the jenkins credentials and populate the mandatory fields.
    
    ![docker agent](https://user-images.githubusercontent.com/39458920/166114026-c72756a5-740b-4686-b9de-8484734d42a5.JPG)

    Once created the docker agent, so we can define the Jenkinsfile to deploy the s3 bucket via terraform commands.
    We had to add the AWS credentials in Jenkins and name them in the jenkinsfile as environment variable.
    
    ```
    pipeline {
    agent {
        label('terraform')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_IN_AUTOMATION      = '1'
    }

    stages {
        stage('dev_init') {
            steps {
                dir('infra') {
                    sh 'terraform init -backend-config="key=infra_dev/terraform.tfstate"'
     ```
     After we built the Infra pipeline, we got the following successful output:
     
    ![pipeline terraform](https://user-images.githubusercontent.com/39458920/166102413-561c4810-7eab-4a1c-9012-0fdc27c76a20.JPG)

    Now we proceed with the storage pipeline to check the s3 bucket size and empty the bucket when it reaches 20 MB
