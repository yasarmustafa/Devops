# resource "aws_instance" "main" {
#   ami           = "ami-043a5a82b6cf98947"
#   instance_type = var.ec2_type

#   tags = {
#     Name        = var.ec2_name
#     Environment = var.environment
#   }
# }
# ---------------------------------------------
# resource "aws_instance" "main" {
#   ami           = "ami-043a5a82b6cf98947"
#   instance_type = var.is_production ? "t2.large" : "t2.micro"

#   tags = {
#     Name        = var.ec2_name
#     Environment = var.is_production ? "Production" : "Development"
#   }
# }
# ---------------------------------------------
# resource "aws_instance" "main" {
#   count         = 2
#   ami           = "ami-043a5a82b6cf98947"
#   instance_type = var.is_production ? "t2.micro" : "t2.large"

#   tags = {
#     Name        = var.ec2_name
#     Environment = var.is_production ? "Production" : "Development"
#   }
# }
# -----------------------------------------------------
# resource "aws_instance" "main" {
#   count         = var.is_production ? 3 : 1
#   ami           = "ami-043a5a82b6cf98947"
#   instance_type = var.is_production ? "t2.large" : "t2.micro"

#   tags = {
#     Name        = "${var.ec2_name}-${count.index + 1}"
#     Environment = var.is_production ? "Production" : "Development"
#   }
# }
# ---------------------------------------------------------------
resource "aws_instance" "main" {
  for_each      = toset(["dev", "test", "prod", "pre-prod"])
  ami           = "ami-043a5a82b6cf98947"
  instance_type = var.is_production ? "t2.micro" : "t2.large"

  tags = {
    Name        = "${each.key}-instance"
    Environment = each.value
  }
}
