output "jenkins_public_ip" {
    description = "Jenkins Public IP"
    value = aws_instance.jenkins_server.public_ip
}