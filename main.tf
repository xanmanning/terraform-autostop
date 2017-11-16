provider "aws" {
  region  = "${var.region}"
  version = "~> 1.2"
}

terraform {
  required_version = ">= 0.9.5"

  backend "s3" {
    bucket = "tf-state-bucket"
    key    = "lambda/stop_start_ec2/terraform.tfstate"
    region = "eu-west-2"
  }
}
