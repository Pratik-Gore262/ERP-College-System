resource "aws_instance" "erp" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t3.micro"

  tags = {
    Name = "ERP-EC2"
  }
}

resource "aws_s3_bucket" "files" {
  bucket = "erp-pratik-2026-demo-002"
}

resource "aws_iam_role" "erp_role" {
  name = "erp-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_db_instance" "erp_db" {
  identifier        = "erp-mysql-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = "erpdb"

  username = "adminuser"
  password = "Pratik12345"

  skip_final_snapshot = true
}
