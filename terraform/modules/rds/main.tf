resource "aws_db_subnet_group" "default" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "default" {
  identifier = "${var.project}-rds"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"  # student allowed
  allocated_storage = 20
  storage_type = "gp3"
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az = false
  publicly_accessible = false
  backup_retention_period = 7
  tags = { Name = "${var.project}-rds" }
}

output "address" { value = aws_db_instance.default.address }
