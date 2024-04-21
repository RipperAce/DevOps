# Initializing connection to aws
provider "aws" {
    region = var.region
}

# Test VPC creation
resource "aws_vpc" "test_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = "Test VPC"
    }
}

# Creation of internet gateway - (Required to create elastic ip else elastic ip can not create)
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.test_vpc.id
    tags = {
      Name = "Testing Internet Gateway"
    }
}

# Creation of elastic ip
resource "aws_eip" "vpc_eip" {
    # for sequential creation i.e. creation after internate gateway
    tags = {
      Name = "Testing EIP"
    }
    depends_on = [ aws_internet_gateway.igw ] 
}

# Creation of nat gateway
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.vpc_eip.id
    subnet_id = aws_subnet.public_subnet1.id
    tags = {
      Name = "Testing NAT Gateway"
    }
}

# Route table for public subnet creation --> route table whose destination is IGW is public route table and it makes subnet to which it is attached public subnet
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.test_vpc.id
    route {
        cidr_block = var.all_cidr
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "Testing Public rt"
    }
}

# Route table for private subnet creation --> route table whose destination is NAT GW is private route table and it makes subnet to which it is attached private subnet. Internet inbound traffic is shut down
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.test_vpc.id
    route {
        cidr_block = var.all_cidr
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }
    tags = {
      Name = "Testing Private rt"
    }
}

# Creation of public subnet 1 in availability zone 1
resource "aws_subnet" "public_subnet1" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.public_subnet1_cidr
    availability_zone = var.availability_zone1
    map_public_ip_on_launch = true
    tags = {
      Name = "Testing Public Subnet 1"
    }
}

# Creation of public subnet 2 in availability zone 2
resource "aws_subnet" "public_subnet2" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.public_subnet2_cidr
    availability_zone = var.availability_zone2
    map_public_ip_on_launch = true
    tags = {
      Name = "Testing Public Subnet 2"
    }
}

# Creation of private subnet in availability zone 2
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.availability_zone2
    tags = {
      Name = "Testing Private Subnet"
    }
}

# Associate public route table with public subnet 1
resource "aws_route_table_association" "public_association1" {
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_subnet1.id
}

# Associate public route table with public subnet 2
resource "aws_route_table_association" "public_association2" {
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_subnet2.id
}

# Associate private route table with private subnet
resource "aws_route_table_association" "private_association" {
    route_table_id = aws_route_table.private_rt.id
    subnet_id = aws_subnet.private_subnet.id
}

# Security group for jenkins. We basically dont care about outbound rule as outbound traffic from our resource does not contaion security risk
# We only care about inbound traffic and for jenkins server it should be able to communicate with 8080 port as that is jenkins port and 22 port which is ssh port for connecting to instance
resource "aws_security_group" "testing_sg" {
      count = length(local.ports_config)
      name = "${local.name[count.index]} SG"
      description = "Open port ${local.ports[count.index]} and 22 for ${local.name[count.index]}"
      vpc_id = aws_vpc.test_vpc.id

      ingress {
        description = "${local.name[count.index]}"
        from_port = local.ports[count.index]
        to_port = local.ports[count.index]
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port = 0
        to_port = 0 #all ports
        protocol = "-1" #all protocols
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "${local.name[count.index]} SG"
      }
}

# Ansible does not have UI so just opening 22 port to connect to ansible server
resource "aws_security_group" "ansible_sg" {
      name = "Ansible SG"
      description = "Open port 22 for Ansible"
      vpc_id = aws_vpc.test_vpc.id

      ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port = 0
        to_port = 0 #all ports
        protocol = "-1" #all protocols
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "Ansible SG"
      }
}

# Load balancer is not an instance but part of networking component
resource "aws_security_group" "lb_sg" {
      name = "LoadBalancer SG"
      description = "Open port 80 for LoadBalancer"
      vpc_id = aws_vpc.test_vpc.id

      ingress {
        description = "LoadBalancer"
        from_port = var.lb_port
        to_port = var.lb_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port = 0
        to_port = 0 #all ports
        protocol = "-1" #all protocols
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "LoadBalancer SG"
      }
}

# Creation of ACL for additional layer of security. ACL are applied to VPC level and are attached to subnets(Mandatory)
# ACL are applied based on their rule number with lowest rule number is applied first than highest one with more priority
resource "aws_network_acl" "acl" {
    vpc_id = aws_vpc.test_vpc.id
    subnet_ids = [ aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id, aws_subnet.private_subnet.id ]
    egress {
        protocol = "tcp"
        rule_no = 100
        cidr_block = var.vpc_cidr
        action = "allow"
        from_port = 0
        to_port = 0
    }

    ingress {
        protocol = "tcp"
        rule_no = 100
        cidr_block = var.all_cidr
        action = "allow"
        from_port = var.lb_port
        to_port = var.lb_port
    }

    ingress {
        protocol = "tcp"
        rule_no = 101
        cidr_block = var.all_cidr
        action = "allow"
        from_port = var.ssh_port
        to_port = var.ssh_port
    }

    ingress {
        protocol = "tcp"
        rule_no = 104
        cidr_block = var.all_cidr
        action = "allow"
        from_port = 9000
        to_port = 9000
    }

    ingress {
        protocol = "tcp"
        rule_no = 103
        cidr_block = var.all_cidr
        action = "allow"
        from_port = 3000
        to_port = 3000
    }

    ingress {
        protocol = "tcp"
        rule_no = 102
        cidr_block = var.all_cidr
        action = "allow"
        from_port = 8080
        to_port = 8080
    }

    tags = {
        Name = "Testing ACL"
    }

}

# ECR for saving docker images which perform scan on push. All must be small case for name
resource "aws_ecr_repository" "docker_ecr" {
    name = "testing_docker_repo"
    image_scanning_configuration {
      scan_on_push = true
    }
}

# Create a key pair to securely connect to servers
# create key value using putty in pem format
resource "aws_key_pair" "auth_key" {
    key_name = var.key_name
    public_key = var.key_value
}