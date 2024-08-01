data "aws_ssm_parameter" "acs_db_password" {
  name            = "/saving-api/${var.environment}/acs_db_password"
  with_decryption = "true"
}
