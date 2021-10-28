terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/google"
      version = ">= 3.90"
    }
  }
}
