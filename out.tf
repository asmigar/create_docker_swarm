output ssh_command {
  value = "ssh ec2-user@${aws_instance.web.public_dns}"
  description = "ssh command for connect to the instance"
}
