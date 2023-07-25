terraform {
  backend "s3" {
    bucket         = "create-docker-swarm-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "create-docker-swarm-state-locks"
    encrypt        = true
    profile        = "default"
  }
}