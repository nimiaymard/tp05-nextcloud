module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

module "security" {
  source                = "../../modules/security"
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  vpc_cidr              = module.networking.vpc_cidr
  s3_primary_bucket_arn = "arn:aws:s3:::placeholder"
  s3_logs_bucket_arn    = "arn:aws:s3:::placeholder"
}

module "data" {
  source                 = "../../modules/data"
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_db_subnet_ids  = module.networking.private_db_subnet_ids
  db_security_group_id   = module.security.db_security_group_id
  kms_key_arn            = module.security.kms_key_arn
  db_password_secret_arn = module.security.db_password_secret_arn
  depends_on             = [module.security]
}

module "compute" {
  source                    = "../../modules/compute"
  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_app_subnet_ids    = module.networking.private_app_subnet_ids
  alb_security_group_id     = module.security.alb_security_group_id
  app_security_group_id     = module.security.app_security_group_id
  app_instance_profile_name = module.security.app_instance_profile_name
  db_endpoint               = module.data.db_endpoint
  db_name                   = module.data.db_name
  db_username               = module.data.db_username
  s3_primary_bucket_name    = module.data.s3_primary_bucket_name
  s3_logs_bucket_name       = module.data.s3_logs_bucket_name
  db_password_secret_arn    = module.security.db_password_secret_arn
  admin_password_secret_arn = module.security.admin_password_secret_arn
}
resource "aws_iam_role_policy" "app_s3_real" {
  name = "nextcloud-dev-app-s3-real"
  role = "nextcloud-dev-app"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "NextcloudS3Objects"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:GetObjectVersion", "s3:AbortMultipartUpload"]
        Resource = "${module.data.s3_primary_bucket_arn}/*"
      },
      {
        Sid      = "NextcloudS3Bucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation", "s3:ListBucketMultipartUploads"]
        Resource = module.data.s3_primary_bucket_arn
      }
    ]
  })
  depends_on = [module.security, module.data]
}
# Outputs utiles pour le rendu
output "vpc_id" {
  value = module.networking.vpc_id
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "db_endpoint" {
  value = module.data.db_endpoint
}

output "s3_primary_bucket_name" {
  value = module.data.s3_primary_bucket_name
}

output "s3_logs_bucket_name" {
  value = module.data.s3_logs_bucket_name
}

output "kms_key_arn" {
  value = module.security.kms_key_arn
}
output "nextcloud_url" {
  value = module.compute.nextcloud_url
}
