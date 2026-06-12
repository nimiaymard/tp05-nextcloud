terraform {
  backend "s3" {
    bucket     = "tf-state-aidekonfreddy-kolab"
    key        = "nextcloud/dev/terraform.tfstate"
    region     = "eu-west-3"
    encrypt    = true
    kms_key_id = "alias/tf-state-aidekonfreddy"
  }
}
