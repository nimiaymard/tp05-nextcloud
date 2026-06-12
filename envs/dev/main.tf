module "networking" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  environment  = var.environment
}

output "vpc_id" { value = module.networking.vpc_id }
output "subnet_id" { value = module.networking.public_subnet_id }
