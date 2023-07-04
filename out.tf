output ssh_command {
  value = <<-SSHCOMMAND
  ssh ec2-user@${aws_instance.manager.public_dns}
  SSHCOMMAND
  description = "ssh command for connect to the instance"
}
