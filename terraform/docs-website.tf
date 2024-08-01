resource "aws_s3_bucket" "docs-bucket" {
  count         = var.environment == "dev" ? 1 : 0
  bucket        = "times-saving-api-docs"
  force_destroy = true

  website {
    index_document = "index.html"
  }

  tags = local.common_tags
}


resource "aws_s3_bucket_policy" "docs-bucket" {
  count  = var.environment == "dev" ? 1 : 0
  bucket = aws_s3_bucket.docs-bucket[count.index].id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "times-saving-api-docs-policy",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::times-saving-api-docs/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ["143.252.0.0/16", "0.0.0.0/16"]
        }
      }
    }
  ]
}
POLICY
}
