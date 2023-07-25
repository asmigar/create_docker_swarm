provider "aws" {
  region  = "us-east-1"
  profile = "default"
  default_tags {
    tags = {
      Organisation = "Self"
      Environment  = "dev"
    }
  }
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "create-docker-swarm-terraform-state"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}