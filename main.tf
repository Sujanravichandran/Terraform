terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.57.0"
    }
  }
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "mnbvcxzzxcvbnm12"
    key            = "global5/s32/terraform.tfstate3"
    region         = "ap-south-1"
    dynamodb_table = "terraform-up-and-running-locks2"
    encrypt        = true
}
}
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "amazon-server" {
  ami           = "ami-01376101673c89611"
  instance_type = "t2.micro"
  tags = {
    Name = "demo-server"
  }
}
resource "aws_s3_bucket" "terraform_state4" {
  bucket = "mnbvcxzzxcvbnm12"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state4.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state4.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state4.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state4.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}