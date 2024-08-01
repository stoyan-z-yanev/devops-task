terraform {
  backend "s3" {
    bucket         = "@S3_BUCKET_NAME"
    region         = "eu-west-1"
    key            = "backup_state/terraform.tfstate"
    dynamodb_table = "@DYNAMO_TABLE"
    encrypt        = true
  }
  required_version = ">= 0.14"
}
