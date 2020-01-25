#!/bin/bash
sudo yum -y install java-1.8.0-openjdk-devel
sudo curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum -y install jenkins git
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo firewall-cmd --permanent --new-service=jenkins
sudo firewall-cmd --permanent --service=jenkins --set-short="Jenkins Service Ports"
sudo firewall-cmd --permanent --service=jenkins --set-description="Jenkins service firewalld port exceptions"
sudo firewall-cmd --permanent --service=jenkins --add-port=8080/tcp
sudo firewall-cmd --permanent --add-service=jenkins
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --reload
