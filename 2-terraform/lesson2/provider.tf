terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region  = "us-east-1" # çalışılacak olan region ismi
  profile = "default"   # .aws dosyasındaki credentials ların bulunduğu profil ismi
  
  # Configuration options
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}