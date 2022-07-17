data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

locals {
  default_tags = merge(var.default_tags, { "Terraform" = "true" })
  prefix       = "EC2-Node-App-"
  random_id    = random_id.this.id
}

resource "random_id" "this" {
  byte_length = 6
}
