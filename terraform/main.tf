# resource "aws_s3_bucket" "udagram" {
#   bucket = var.bucket_name
#   acl    = "private"

#   tags = {
#     Environment = "Dev"
#   }

#   cors_rule {
#     allowed_origins = ["*"]
#     allowed_headers = ["*"]
#     allowed_methods = ["PUT", "POST", "DELETE"]
#   }

#   force_destroy = true
# }

# resource "aws_s3_bucket_public_access_block" "udagram" {
#   bucket = aws_s3_bucket.udagram.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# if required
# data "aws_iam_policy_document" "udagram_bucket" {
#   version = "2012-10-17"
#   statement {
#     sid    = "S3AccessPolicy"
#     effect = "Allow"
#     resources = [
#       aws_s3_bucket.udagram.arn
#     ]
#     actions = [
#       "s3:ListBucket",
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:DeleteObject"
#     ]
#   }
# }

resource "aws_db_instance" "udagram" {
  identifier           = var.db_identifier
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.4"
  instance_class       = "db.t2.micro"
  name                 = var.db_name
  username             = "udagram"
  password             = var.db_password
  parameter_group_name = "default.postgres12"
  skip_final_snapshot  = true
}
