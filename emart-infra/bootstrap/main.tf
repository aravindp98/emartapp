terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.55"
    }
  }
}

locals {
  s3_bucket_name = "emart-infra-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "tf_state" {
    bucket = local.s3_bucket_name
    tags = {
        Name        = "eMart Infrastructure State Bucket"
        Environment = "Production"
    }  
}

resource "aws_s3_bucket_public_access_block" "state_block_public" {
    bucket = aws_s3_bucket.tf_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "emart-infra-tf-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "eMart State Lock Table"
    Environment = "Production"
  }
}

data "aws_caller_identity" "current" {}