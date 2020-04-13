output "public_ip" {
  value = "${aws_instance.tomcat-instance.public_ip}"
}