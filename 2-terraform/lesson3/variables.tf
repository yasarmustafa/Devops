variable "ec2_name" {
  default = "my-EC2-instance"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "environment" {
  default = "dev"
}

variable "is_production" {
  default = "true"
}

variable "names" {
  default = ["dev", "test", "prod"]
}

# variable "region_map" {
#   default = {
#     us-east-1 = "Virginia"
#     us-west-1 = "California"
#   }
# }
variable "numbers" {
  default = [1, 2, 3, 4, 5, 33, 44, 55, 40]
}
variable "region_map" {
  default = {
    "us-east-1"    = "Virginia"
    "us-west-1"    = "California"
    "eu-central-1" = "Frankfurt"
  }
}