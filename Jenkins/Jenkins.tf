provider "aws" {
  profile    = "default"
  region     = "us-east-2"
}

resource "aws_instance" "myinstance" {
  ami           = "ami-0e58b083ed4c66b2b"
  instance_type = "t2.medium"
  availability_zone = "us-east-2a"
  key_name = "jenkins-key"
  security_groups = [aws_security_group.sec_jenkins.name]
  root_block_device {
    volume_size = "20"
  }
  connection {
    type = "ssh"
    user = "maintuser"
    host = aws_instance.myinstance.public_ip
    timeout = "1m"
    private_key = file("/root/.ssh/id_rsa")
  }


  provisioner "local-exec" {
    command = "sleep 240;ssh-keyscan ${aws_instance.myinstance.public_ip} >> /root/.ssh/known_hosts;ssh-keyscan ${aws_instance.myinstance.public_dns} >> /root/.ssh/known_hosts"
  }

  provisioner "file" {
    source = "installation_sripts/installJenkins.sh"
    destination = "/home/maintuser/installJenkins.sh"
  }
  provisioner "remote-exec" {

    inline = [
      "chmod +x /home/maintuser/installJenkins.sh",
      "/home/maintuser/installJenkins.sh",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]
    }
}

resource "aws_security_group" "sec_jenkins" {
  name           = "sec_jenkins"

  # Enabling SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

   # HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

# HTTP_for_jenkins
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }


  # HTTPS
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # Jenkins JNLP port
  ingress {
    from_port = 50000
    to_port = 50000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_ebs_volume" "ebs-volume1" {
  availability_zone = aws_instance.myinstance.availability_zone
  type              = "gp2"
  size              = 50
}

resource "aws_volume_attachment" "ebs-volume1-attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.myinstance.id
  volume_id   = aws_ebs_volume.ebs-volume1.id
}

resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/bygbUwzTDEgM8G38bqNPYwaDD9ZI7pBYpVBaS7VXMeNqpz5wSmmXV0Urnw5BmWwQrZBW7BYI6sNpY/l3Ev3LbyvT423sIfSQ1sdGsTtVKurOo9gBxjKgxqrReudVFAUa4JsNCRI5K7G4ef9gqAH3pTN9KUXR5uaUKK+aiOptkuAm5m77VEmSRwkFm+sIAfy4u7zQaj2gYH/YRrNmV1Bx70RF6QlMxiYVjgD8R8GG72msA/Ek+fGoaUl8paoQs8c5En/auNd8xoOAYIo5SmW5moGQs4mY858xn/g3KmNrckAZ5WWeVg6SiPa4UkcjSi6D8dVEW5IFgOsZ9sYEbEex root@ip-172-31-40-204.us-east-2.compute.internal"
}


