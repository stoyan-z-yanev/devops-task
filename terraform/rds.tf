resource "aws_db_subnet_group" "saving-api-cluster-subnet" {
  name       = "saving-api-cluster-${var.environment}"
  subnet_ids = [aws_subnet.eu-west-1a-private.id, aws_subnet.eu-west-1b-private.id, aws_subnet.eu-west-1c-private.id]

  tags = merge(
    tomap({
      "Name" = "DB subnet group for Saving API Aurora Cluster",
    }),
    local.common_tags
  )
}

resource "aws_rds_cluster" "postgresql" {
  apply_immediately           = true
  cluster_identifier          = "times-saving-cluster-${var.environment}"
  engine                      = "aurora-postgresql"
  engine_version              = "12.12"
  availability_zones          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_name               = "saving_api_${var.environment}"
  master_username             = var.master_cluster_username
  master_password             = random_string.aurora_cluster_password.result
  db_subnet_group_name        = aws_db_subnet_group.saving-api-cluster-subnet.name
  backup_retention_period     = 5
  preferred_backup_window     = "03:00-05:00"
  skip_final_snapshot         = "false"
  final_snapshot_identifier   = "saving-api-cluster-${var.environment}-final-snapshot-${random_string.postgresql.result}"
  vpc_security_group_ids      = [aws_default_security_group.default.id]
  storage_encrypted           = "true"
  kms_key_id                  = aws_kms_alias.saving_api_key_restricted.target_key_arn
  deletion_protection         = true
  allow_major_version_upgrade = true
  tags = merge(
    tomap({
      "cluster_name" = "Times Saving API cluster ${var.environment}",
    }),
    local.common_tags
  )
}

resource "random_string" "postgresql" {
  length  = 8
  upper   = true
  special = false
  lower   = false
  number  = false

  keepers = {
    value = "${var.master_cluster_username}-${aws_db_subnet_group.saving-api-cluster-subnet.name}-${aws_kms_alias.saving_api_key_restricted.target_key_arn}"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                      = var.cluster_instance_count
  identifier                 = "saving-api-aurora-instance-${var.environment}-${count.index}"
  cluster_identifier         = aws_rds_cluster.postgresql.id
  instance_class             = var.cluster_instance_size
  engine                     = "aurora-postgresql"
  engine_version             = "12.12"
  db_subnet_group_name       = aws_db_subnet_group.saving-api-cluster-subnet.name
  depends_on                 = [aws_db_subnet_group.saving-api-cluster-subnet]
  auto_minor_version_upgrade = false
  copy_tags_to_snapshot      = true

  tags = merge(
    tomap({
      "Name" = "saving-api-aurora-instance-${var.environment}-${count.index}"
    }),
    local.common_tags
  )
}

resource "aws_route53_record" "aurora_cluster" {
  zone_id = var.hosted_zone_id
  name    = "saving-api-db-${var.environment}"
  type    = "CNAME"
  ttl     = "600"
  records = [aws_rds_cluster.postgresql.endpoint]
}
