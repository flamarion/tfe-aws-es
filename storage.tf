#Random id
resource "random_id" "id" {
  byte_length = 3
}

# S3 Bucket
resource "aws_s3_bucket" "tfe_s3" {
  bucket        = "${var.owner}-tfe-es-${random_id.id.hex}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
  tags = {
    "Name" = "${var.owner}-tfe-es-s3"
  }
}
