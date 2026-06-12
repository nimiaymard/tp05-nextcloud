# Certificat auto-signe pour le HTTPS de l'ALB.

resource "tls_private_key" "self_signed" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Certificat valide 2 ans
resource "tls_self_signed_cert" "alb" {
  private_key_pem = tls_private_key.self_signed.private_key_pem

  subject {
    common_name  = "${local.name_prefix}.kolab.local"
    organization = "Kolab Cabinet Avocats"
  }

  validity_period_hours = 17520

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  # Domaines couverts par le certificat
  dns_names = [
    "${local.name_prefix}.kolab.local",
    "*.elb.amazonaws.com",
    "*.eu-west-3.elb.amazonaws.com",
  ]
}

# Import du certificat dans ACM
resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.self_signed.private_key_pem
  certificate_body = tls_self_signed_cert.alb.cert_pem

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}
