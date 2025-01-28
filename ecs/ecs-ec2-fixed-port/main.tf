terraform {
  backend "s3" {
    bucket         = "spring-clinic-779846826293"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "spring-clinic-779846826293-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      project            = "spring-petclinic"
      Environment        = terraform.workspace
      ManagedByTerraform = "True"
    }
  }
}
