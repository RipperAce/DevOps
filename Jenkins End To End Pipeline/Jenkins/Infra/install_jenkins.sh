#!/bin/bash

#Update the system
sudo yum update -y

#Add jenkins repo to yum
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

#Import key file
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

#Upgrade as key imported
sudo yum upgrade

#Install java 17
sudo dnf install java-17-amazon-corretto -y

#Install jenkins
sudo yum install jenkins -y

#Enable that jenkins service starts on machine reboot
sudo systemctl enable jenkins

#Start jenkins service
sudo systemctl start jenkins