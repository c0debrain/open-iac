terraform {
  required_version = ">= 0.8, < 0.12"
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "tomcat-instance" {
  //ami                    = "ami-0af93e2cdbf1966f0"
  //ami                      = "ami-048fb0425425e2515" //custom tomcat
  ami                       = "ami-0ebb772edcdd25633" //tomcat confd
  //ami                    = "ami-0e1e47104500d5c4d" //ubuntu 18 small
  //ami                    = "ami-04fcc97b5f6edcd89" //ubuntu 18
  //ami                    = "ami-0dd7dc2dbce8d7454" //free bsd
  //ami                      = "ami-0b0c5c907b0ce660d" //free bsd 12.1 ap-se2
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance-http-sg.id}","${aws_security_group.instance-ssh-sg.id}"]
  key_name = "${aws_key_pair.instance-key.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.name}"
  user_data = <<-EOF
              #!/bin/bash
              //echo "Hello, World" > index.html
              //nohup busybox httpd -f -p "${var.server_port}" &
              //sudo systemctl start tomcat
              EOF

  tags {
    Name = "tomcat-instance"
  }
}

resource "aws_security_group" "instance-http-sg" {
  name = "instance-http-sg"
  ingress {
    from_port   = "80"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance-ssh-sg" {
  name = "instance-ssh-sg"
   ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "instance-key" {
  key_name   = "instance-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7KSzm5GmKG6URtnSOtoul76FCckSGeau1Dqm8/KkETpxg88JPNjW1SlGkr4RRtCRXy1LX4p9xh8T6pMar6T3GAGoGvQSXHJTe5djreID/1A91GX7Cdaw1eppQ8O2y+h2M0+1aHLczzRoPl95guaSYPYEUn2v6OrGstPjCPieLVQglVi9925icv1kxsG2HtV5KZErbFKI9puhXBXvyBH7P0B92O3ppUHAvve6vXfe8jZEOR/wN6GFijHDeOBMyPVWckwpbxxhMBkA/6WX23r08fOqkDVn96VfyqbikKx4DY/TpcJntTjQjoJgVZofQyejTzpTFAO1C/DoDZdMwrfP5 codebrain@gmail.com"
}

resource "aws_ssm_parameter" "secret" {
  name        = "/${var.environment}/sample-secret"
  description = "The parameter description"
  type        = "SecureString"
  value       = "somepassword"

  tags = {
    environment = "${var.environment}"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = "${aws_iam_role.ec2_role.name}"
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = "${aws_iam_role.ec2_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ssm:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}