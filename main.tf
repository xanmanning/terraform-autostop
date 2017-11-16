provider "aws" {
  region  = "${var.region}"
  version = "~> 1.2"
}

terraform {
  required_version = ">= 0.9.5"
}
