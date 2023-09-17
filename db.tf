resource "aws_db_instance" "default" {
  allocated_storage           = 10
  db_name                     = "mydb"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  manage_master_user_password = true
  username                    = "dbadmin"

  iam_database_authentication_enabled = true
  db_subnet_group_name                = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name = "My DB subnet group"
  }
}