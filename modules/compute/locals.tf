locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Conversion map -> liste pour l'ALB et l'ASG
  public_subnet_ids_list      = values(var.public_subnet_ids)
  private_app_subnet_ids_list = values(var.private_app_subnet_ids)

  aws_region = "eu-west-3"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "compute"
    Owner       = "etudiant21"
  }
}
