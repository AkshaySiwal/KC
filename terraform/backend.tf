terraform {
  backend "s3" {
    bucket         = "knowledgecity-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "me-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
