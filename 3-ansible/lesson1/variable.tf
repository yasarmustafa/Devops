variable "tags" {
  default = ["control_node", "node_1", "node_2"]
}
variable "key_name" {
  default = "mustafayasar" # Replace with your actual key pair name
}
variable "user" {
  default = "session1"
}

variable "amznlnx2023" {
  default = "ami-02457590d33d576c3" # Amazon Linux 2023 AMI ID for eu-west-1
}

variable "ubuntu" {
  default = "ami-0f9de6e2d2f067fca" # Ubuntu 22.04 AMI ID for eu-west-1
}

variable "instance_type" {
  default = "t2.micro"
}

# variable "aws_secret_key" {
#  default = "xxxxx"
# }

# variable "aws_access_key" {
#  default = "xxxxx"
# }