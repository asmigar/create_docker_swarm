variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

variable "enable_workers" {
  type = bool
  default = true
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "AWS instance type to be used for docker swarm manager and worker node"
}
