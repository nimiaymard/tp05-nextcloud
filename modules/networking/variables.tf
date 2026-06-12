variable "project_name" {
  description = "Nom de projet pour le tagging Name."
  type        = string
}

variable "environment" {
  description = "Nom de l environnement (dev, staging)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block du VPC (/16 recommande)."
  type        = string
  default     = "10.30.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Doit etre un CIDR IPv4 valide."
  }
}

variable "azs" {
  description = "Liste des AZ. 2 AZ exactement pour ce TP."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]

  validation {
    condition     = length(var.azs) == 2
    error_message = "Exactement 2 AZ attendues."
  }
}