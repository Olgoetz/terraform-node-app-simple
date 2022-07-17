terraform {

  required_version = ">= 1.0.0"


  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }
}