# data to fetch subnet id based on tag
data "aws_subnet" "public_subnet1" {
    filter {
      name = "tag:Name"
      values = [ "Testing Public Subnet 1" ]
    }
}

# data to fetch security group id for jenkins
data "aws_security_group" "jenkins_sg" {
    filter {
      name = "tag:Name"
      values = [ "Jenkins SG" ]
    }
}