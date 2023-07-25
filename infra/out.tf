output "ssh_command_manager_node" {
  value       = <<-SSHCOMMAND
  ssh ${aws_instance.manager.public_dns}
  SSHCOMMAND
  description = "ssh command for connecting to the manager node"
}

output "ssh_command_worker_nodes" {
  value       = <<-SSHCOMMAND
  %{for dns in aws_instance.worker[*].public_dns}
  ssh ${dns}
  %{endfor}
  SSHCOMMAND
  description = "ssh command for connect to the worker node"
}
