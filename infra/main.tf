variable "bucket_name" {}

resource "aws_s3_bucket" "secure_store" {
  bucket = "${var.bucket_name}"
  acl = "private"
}

resource "aws_kms_key" "primary" {
  description = "ES Key"
}

output "s3_bucket" {
  value = "${aws_s3_bucket.secure_store.id}"
}

output "key_id" {
  value = "${aws_kms_key.primary.id}"
}
