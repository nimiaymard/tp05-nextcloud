output "db_endpoint" {
  value       = aws_db_instance.nextcloud.address
  description = "Hostname RDS (sans port)"
}

output "db_port" {
  value       = aws_db_instance.nextcloud.port
  description = "Port PostgreSQL (5432)"
}

output "db_name" {
  value       = aws_db_instance.nextcloud.db_name
  description = "Nom de la base logique"
}

output "db_username" {
  value       = aws_db_instance.nextcloud.username
  description = "User master PostgreSQL"
}

output "s3_primary_bucket_name" {
  value       = aws_s3_bucket.primary.bucket
  description = "Nom du bucket primary storage"
}

output "s3_primary_bucket_arn" {
  value       = aws_s3_bucket.primary.arn
  description = "ARN du bucket primary"
}

output "s3_logs_bucket_name" {
  value       = aws_s3_bucket.logs.bucket
  description = "Nom du bucket access logs ALB"
}

output "s3_logs_bucket_arn" {
  value       = aws_s3_bucket.logs.arn
  description = "ARN du bucket logs"
}
