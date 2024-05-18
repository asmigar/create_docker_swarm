terraform {
  backend "s3" {
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "create-docker-swarm-state-locks"
    encrypt        = true
    profile        = "asmigar"
  }
}
