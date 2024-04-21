# s3 bucket to store state file of terraform
# run only once to create bucket
# resource "aws_s3_bucket" "devops_terraform_backend_bucket" {
#     bucket = "testing-devops-terrafrom-state-bucket"
#     acl = "private"
#     versioning {
#       enabled = true
#     }
# }


# backend declaration to store state file in s3. After declaring this need to run init command
# Variables can not be used in backend
terraform {
  backend "s3" {
    bucket = "testing-devops-terrafrom-state-bucket"
    key = "state/terraform.tfstate"
    region = "ap-southeast-1"
  }
}