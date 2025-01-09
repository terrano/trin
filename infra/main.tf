terraform {
  backend "s3" {
    bucket         = "spring-clinic"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "spring-clinic-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project            = "spring-petclinic"
      Environment        = terraform.workspace
      ManagedByTerraform = "True"
    }
  }
}
