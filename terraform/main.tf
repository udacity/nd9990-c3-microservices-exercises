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
  identifier             = var.db_identifier
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "12.4"
  instance_class         = "db.t2.micro"
  name                   = var.db_name
  username               = "udagram"
  password               = var.db_password
  parameter_group_name   = "default.postgres12"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.udagram.id]
  db_subnet_group_name   = aws_db_subnet_group.udagram.name
}

resource "aws_db_subnet_group" "udagram" {
  name       = "udagram-db-subnet"
  subnet_ids = [aws_subnet.udagram_1.id, aws_subnet.udagram_2.id]

  tags = {
    Name = "Udagram DB subnet"
  }
}

resource "aws_vpc" "udagram" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "udagram-vpc"
  }
}

resource "aws_subnet" "udagram_1" {
  vpc_id            = aws_vpc.udagram.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "udagram-subnet-1"
  }
}

resource "aws_subnet" "udagram_2" {
  vpc_id            = aws_vpc.udagram.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1d"

  tags = {
    Name = "udagram-subnet-2"
  }
}

resource "aws_security_group" "udagram" {
  name   = "udagram-security-group"
  vpc_id = aws_vpc.udagram.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "udagram_dev"
  }
}

resource "aws_internet_gateway" "udagram" {
  vpc_id = aws_vpc.udagram.id

  tags = {
    Name = "udagram-internet-gateway"
  }
}
