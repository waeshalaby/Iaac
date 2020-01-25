provider "aws" {
  profile    = "default"
  region     = "us-east-2"
}

resource "aws_instance" "es-instance" {
  ami           = "ami-0e58b083ed4c66b2b"
  instance_type = "t2.medium"
  availability_zone = "us-east-2a"
  key_name = "jenkins-key"
  security_groups = [aws_security_group.sec_ES.name]
  root_block_device {
    volume_size = "30"
  }
  connection {
    type = "ssh"
    user = "maintuser"
    host = aws_instance.es-instance.public_ip
    timeout = "1m"
    private_key = file("/root/.ssh/id_rsa")
  }


  provisioner "local-exec" {
    command = "sleep 240;ssh-keyscan ${aws_instance.es-instance.public_ip} >> /root/.ssh/known_hosts;ssh-keyscan ${aws_instance.es-instance.public_dns} >> /root/.ssh/known_hosts"
  }

  provisioner "file" {
    source = "installation_sripts/installES.sh"
    destination = "/home/maintuser/installES.sh"
  }
  provisioner "remote-exec" {

    inline = [
      "chmod +x /home/maintuser/installES.sh",
      "/home/maintuser/installES.sh"
    ]
    }
}

resource "aws_security_group" "sec_ES" {
  name           = "sec_ES"

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

# HTTP_for_elastic
  ingress {
    from_port = 9200
    to_port = 9200
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
  availability_zone = aws_instance.es-instance.availability_zone
  type              = "gp2"
  size              = 50
}

resource "aws_volume_attachment" "ebs-volume1-attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.es-instance.id
  volume_id   = aws_ebs_volume.ebs-volume1.id
}


