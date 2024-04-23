provider "aws" {
    region = var.region
}

terraform {
  backend "s3" {
    bucket = "testing-devops-terrafrom-state-bucket"
    key = "jenkins/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Create ec2 instance which serves as jenkins server. Use user data to install jenkins on it
# attach it to public subnet 1
resource "aws_instance" "jenkins_server" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = data.aws_subnet.public_subnet1.id
    availability_zone = data.aws_subnet.public_subnet1.availability_zone
    vpc_security_group_ids = [data.aws_security_group.jenkins_sg.id]
    key_name = "testing_key"
    user_data = file("./install_jenkins.sh")

    volume_tags = {
      Name = "Jenkins-Server"
      Product = "Studio"
      BudgetTeam = "FMC"
      Service = "CI"
      Environment = "dev"
      EnvType = "non-prod"
      DeleteProtection = "5"
      ShutdownProtection = "0"
      Team = "FMC"
      Owner = "random@gmail.com"
      CC = "True"
      map-migrated = "d-server-00p12lc5ca5o8n"
    }
    tags = {
      Name = "Jenkins-Server"
      Product = "Studio"
      BudgetTeam = "FMC"
      Service = "CI"
      Environment = "dev"
      EnvType = "non-prod"
      DeleteProtection = "5"
      ShutdownProtection = "0"
      Team = "FMC-Studio"
      Owner = "random@gmail.com"
      CC = "True"
      map-migrated = "mig40419"
    }
} 