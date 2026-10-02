terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# =========================================================
# AVAILABILITY ZONES
# =========================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "erp_vpc_new" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "ERP-VPC-NEW"
    Project = "ERP-College-System"
  }
}

# =========================================================
# INTERNET GATEWAY
# =========================================================

resource "aws_internet_gateway" "erp_igw_new" {
  vpc_id = aws_vpc.erp_vpc_new.id

  tags = {
    Name = "ERP-IGW-NEW"
  }
}

# =========================================================
# PUBLIC SUBNET - EC2
# =========================================================

resource "aws_subnet" "public_subnet_new" {
  vpc_id                  = aws_vpc.erp_vpc_new.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "ERP-Public-Subnet-NEW"
  }
}

# =========================================================
# PRIVATE SUBNET 1 - RDS
# =========================================================

resource "aws_subnet" "private_subnet_1_new" {
  vpc_id            = aws_vpc.erp_vpc_new.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "ERP-Private-Subnet-1-NEW"
  }
}

# =========================================================
# PRIVATE SUBNET 2 - RDS
# =========================================================

resource "aws_subnet" "private_subnet_2_new" {
  vpc_id            = aws_vpc.erp_vpc_new.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "ERP-Private-Subnet-2-NEW"
  }
}

# =========================================================
# PUBLIC ROUTE TABLE
# =========================================================

resource "aws_route_table" "public_route_new" {
  vpc_id = aws_vpc.erp_vpc_new.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.erp_igw_new.id
  }

  tags = {
    Name = "ERP-Public-Route-NEW"
  }
}

# =========================================================
# ROUTE TABLE ASSOCIATION
# =========================================================

resource "aws_route_table_association" "public_association_new" {
  subnet_id      = aws_subnet.public_subnet_new.id
  route_table_id = aws_route_table.public_route_new.id
}

# =========================================================
# EC2 SECURITY GROUP
# =========================================================

resource "aws_security_group" "ec2_security_new" {
  name        = "erp-ec2-security-new"
  description = "Security group for ERP EC2"
  vpc_id      = aws_vpc.erp_vpc_new.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ERP-EC2-Security-NEW"
  }
}

# =========================================================
# RDS SECURITY GROUP
# =========================================================

resource "aws_security_group" "rds_security_new" {
  name        = "erp-rds-security-new"
  description = "Security group for ERP RDS"
  vpc_id      = aws_vpc.erp_vpc_new.id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_security_new.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ERP-RDS-Security-NEW"
  }
}

# =========================================================
# IAM ROLE
# =========================================================

resource "aws_iam_role" "erp_role_new" {
  name = "erp-ec2-role-new-2026"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "ERP-EC2-Role-NEW"
    Project = "ERP-College-System"
  }
}

# =========================================================
# S3 BUCKET
# =========================================================

resource "aws_s3_bucket" "erp_storage_new" {
  bucket = "erp-pratik-college-2026-new-001"

  tags = {
    Name    = "ERP-Storage-NEW"
    Project = "ERP-College-System"
  }
}

# =========================================================
# S3 VERSIONING
# =========================================================

resource "aws_s3_bucket_versioning" "erp_storage_versioning" {
  bucket = aws_s3_bucket.erp_storage_new.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# S3 ENCRYPTION
# =========================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "erp_storage_encryption" {
  bucket = aws_s3_bucket.erp_storage_new.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# =========================================================
# S3 PUBLIC ACCESS BLOCK
# =========================================================

resource "aws_s3_bucket_public_access_block" "erp_storage_public_block" {
  bucket = aws_s3_bucket.erp_storage_new.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# IAM POLICY - S3 ACCESS
# =========================================================

resource "aws_iam_role_policy" "erp_s3_policy_new" {
  name = "erp-s3-policy-new"
  role = aws_iam_role.erp_role_new.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]

        Resource = [
          aws_s3_bucket.erp_storage_new.arn,
          "${aws_s3_bucket.erp_storage_new.arn}/*"
        ]
      }
    ]
  })
}

# =========================================================
# IAM INSTANCE PROFILE
# =========================================================

resource "aws_iam_instance_profile" "erp_profile_new" {
  name = "erp-ec2-profile-new-2026"
  role = aws_iam_role.erp_role_new.name
}

# =========================================================
# EC2 INSTANCE
# =========================================================

resource "aws_instance" "erp_server_new" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet_new.id

  vpc_security_group_ids = [
    aws_security_group.ec2_security_new.id
  ]

  iam_instance_profile = aws_iam_instance_profile.erp_profile_new.name

  tags = {
    Name        = "ERP-EC2-Server-NEW"
    Project     = "ERP-College-System"
    Environment = "Demo"
  }
}

# =========================================================
# RDS SUBNET GROUP
# =========================================================

resource "aws_db_subnet_group" "erp_db_subnet_new" {
  name = "erp-db-subnet-new-2026"

  subnet_ids = [
    aws_subnet.private_subnet_1_new.id,
    aws_subnet.private_subnet_2_new.id
  ]

  tags = {
    Name = "ERP-RDS-Subnet-NEW"
  }
}

# =========================================================
# RDS MYSQL DATABASE
# =========================================================

resource "aws_db_instance" "erp_database_new" {
  identifier = "erp-mysql-new-2026"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "erpdb"
  username = "adminuser"
  password = var.db_password

  port = 3306

  db_subnet_group_name = aws_db_subnet_group.erp_db_subnet_new.name

  vpc_security_group_ids = [
    aws_security_group.rds_security_new.id
  ]

  publicly_accessible = false

  backup_retention_period = 0

  skip_final_snapshot = true

  deletion_protection = false

  tags = {
    Name        = "ERP-MySQL-Database-NEW"
    Project     = "ERP-College-System"
    Environment = "Demo"
  }
}

# =========================================================
# OUTPUTS
# =========================================================

output "vpc_id" {
  value = aws_vpc.erp_vpc_new.id
}

output "ec2_public_ip" {
  value = aws_instance.erp_server_new.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.erp_server_new.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.erp_storage_new.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.erp_database_new.endpoint
}

output "rds_database_name" {
  value = aws_db_instance.erp_database_new.db_name
}
