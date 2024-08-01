resource "aws_kms_key" "saving_api_key" {
  description = "KMS for /saving-api/${var.environment}/cluster_password"

  tags = merge(
    tomap({
      "Name" = "/saving-api/${var.environment}/cluster_password"
    }),
    local.common_tags
  )
}



resource "aws_kms_key" "saving_api_key_restricted" {
  description = "KMS for /saving-api/${var.environment}/api_db_password"
  tags = merge(
    tomap({
      "Name" = "/saving-api/${var.environment}/api_db_password"
    }),
    local.common_tags
  )
}

resource "aws_kms_alias" "saving_api_key" {
  name          = "alias/saving-api-key-${var.environment}"
  target_key_id = aws_kms_key.saving_api_key.key_id
}

resource "aws_kms_alias" "saving_api_key_restricted" {
  name          = "alias/saving-api-key-restricted-${var.environment}"
  target_key_id = aws_kms_key.saving_api_key_restricted.key_id
}

resource "random_string" "aurora_cluster_password" {
  length           = 16
  special          = true
  override_special = "!#$&*()-_=[]{}<>?"

  keepers = {
    key = aws_kms_key.saving_api_key.key_id
  }
}

resource "random_string" "api_db_password" {
  length           = 16
  special          = true
  override_special = "/@ "

  keepers = {
    key = aws_kms_key.saving_api_key_restricted.key_id
  }
}

resource "aws_ssm_parameter" "aurora_cluster_password" {
  name      = "/saving-api/${var.environment}/cluster_password"
  type      = "SecureString"
  value     = random_string.aurora_cluster_password.result
  key_id    = aws_kms_key.saving_api_key.key_id
  overwrite = true

  tags = merge(
    tomap({
      "Name" = "/saving-api/${var.environment}/cluster_password"
    }),
    local.common_tags
  )
}

resource "aws_ssm_parameter" "api_db_password" {
  name      = "/saving-api/${var.environment}/api_db_password"
  type      = "SecureString"
  value     = random_string.api_db_password.result
  key_id    = aws_kms_key.saving_api_key_restricted.key_id
  overwrite = true

  tags = merge(
    tomap({
      "Name" = "/saving-api/${var.environment}/api_db_password"
    }),
    local.common_tags
  )
}

output "aurora_cluster_password_resource" {
  value = aws_ssm_parameter.aurora_cluster_password.arn
}

output "api_db_password_resource" {
  value = aws_ssm_parameter.api_db_password.arn
}
