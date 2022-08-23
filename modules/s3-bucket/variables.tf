variable "resource_tags" {
  description = "Tags for S3 buckets"
  type        = map
  default     = {}
}

variable "bucket_acl" {
  description = "S3 bucket ACL setting"
  type = string
}

variable "versioning_enabled" {
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket"
  type        = bool
}