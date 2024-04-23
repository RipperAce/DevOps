provider "aws" {
    region = var.region
}

terraform {
  backend "s3" {
    bucket = "testing-devops-terrafrom-state-bucket"
    key = "sonarqube/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

resource "aws_instance" "sonarqube_server" {
    ami = var.ami_id
    instance_type = var.instance_type
    availability_zone = data.aws_subnet.public_subnet.availability_zone
    subnet_id = data.aws_subnet.public_subnet.id
    vpc_security_group_ids = [ data.aws_security_group.sonarqube_sg.id ]
    key_name = "testing_key"

    volume_tags = {
        Name = "SonarQube-Server"
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
        Name = "SonarQube-Server"
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