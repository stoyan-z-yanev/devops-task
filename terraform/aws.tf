provider "aws" {
  region = var.aws_region
}

locals {
  product_id = "times-saving-api"
  common_tags = {
    ServiceCatalogueId = "253"
    ServiceName        = local.product_id
    Environment        = var.environment
  }
}
