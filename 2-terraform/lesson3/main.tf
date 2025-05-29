resource "aws_instance" "main" {
  ami           = "ami-043a5a82b6cf98947"
  instance_type = var.ec2_type

  tags = {
    Name        = var.ec2_name
    Environment = var.environment
  }
}