resource "aws_s3_bucket" "badbucket" {
  acl = var.bucket_acl
  
  versioning {
    enabled = var.versioning_enabled
  }

  tags = var.resource_tags
}