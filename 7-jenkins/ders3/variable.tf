//variable "aws_secret_key" {}
//variable "aws_access_key" {}
variable "region" {
  default = "us-east-1"
    description = "North-Virginia region"
}
variable "mykey" {
  default = "mustafayasar"
  description = "benim-keyim"
}
variable "tags" {
  default = "jenkins-server"
}

variable "instancetype" {
  default = "t3a.medium"
}

variable "secgrname" {
  default = "jenkins-server-sec-gr"
}