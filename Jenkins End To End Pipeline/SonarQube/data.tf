data "aws_security_group" "sonarqube_sg" {
    filter {
      name = "tag:Name"
      values = ["Sonarqube SG"]
    }
}

data "aws_subnet" "public_subnet" {
    filter {
      name = "tag:Name"
      values = [ "Testing Public Subnet 1" ]
    }
}