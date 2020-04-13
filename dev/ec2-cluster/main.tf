terraform {
  required_version = ">= 0.8, < 0.12"
}

provider "aws" {
   region = "ap-southeast-2"
}

resource "aws_launch_configuration" "tomcat-cluster" {
  image_id        = "ami-048fb0425425e2515"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.tomcat-cluster.id}"]

  user_data = <<-EOF
              #!/bin/bash
              //echo "Hello, World" > index.html
              //nohup busybox httpd -f -p "${var.server_port}" &
              sudo systemctl start tomcat
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tomcat-asg" {
  launch_configuration = "${aws_launch_configuration.tomcat-cluster.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.tomcat-cluster.name}"]
  health_check_type = "ELB"

  min_size = 1
  max_size = 3

  tag {
    key                 = "Name"
    value               = "tomcat-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "tomcat-cluster" {
  name = "tomcat-cluster"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "tomcat-cluster" {
  name               = "tomcat-asg"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "tomcat-cluster-elb"

  ingress {
    from_port   = 80
    to_port     = 8080
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
