resource "aws_instance" "main" {

  ami            = "ami-0e58b56aa4d64231b" # us-east-1 için AMI - mevcut regioan da geçerli bir ami_id girilmeli
  instance_type = "t2.micro"

  tags = {
    Name        = "EC2-TerraformV2"
    Environment = "test"
  }
}