terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
      #version = "~> 5.0"
      #version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1" # çalışılacak olan aws region ismi
  profile = "default"   # .aws dosyasındaki ($ echo $HOME/.aws) credentials ların bulunduğu profil ismi
  
  # Configuration options
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}