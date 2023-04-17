locals {
  resource_name_prefix = "${var.business_division}-${var.environment}"
}

locals {
  common_tags = {
    environment = var.environment
  }
}
