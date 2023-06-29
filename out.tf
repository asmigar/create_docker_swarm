output "instance_public_ip" {
  value = aws_instance.web.public_ip
  description = "Public ip of the instance to connect to"
}