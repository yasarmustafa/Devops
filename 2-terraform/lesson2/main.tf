#resource "aws_instance" "main" {
# ami           = data.aws_ami.latest_ubuntu.id
#  instance_type = "t2.micro"

#  tags = {
#    Name        = "EC2-terraform-ubuntu"
#    Environment = "test"
#  }
#}
# resource "aws_instance" "main" {
#   ami           = data.aws_ami.latest_ubuntu.id
#   instance_type = "t2.micro"

#   tags = {
#     Name        = "${local.Name}-my-local-name" # not string içinde başka bir bloktan veri alma
#     Environment = "${local.environment}"              # local bloğundaki environmetn değişkenini kullanmak için local.environment
#     #Environment = local.environment        # local bloğundaki environmetn değişkenini kullanmak için local.environment
#   }
# }
resource "aws_instance" "main" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.ec2_type

  tags = {
    Name        = var.ec2_name
    Environment = var.environment
  }
}
resource "aws_instance" "imported" {
  ami           = "ami-0953476d60561c955"
  instance_type = "t2.micro"

  tags = {
    Name        = "imported-instance"
    Environment = "imported"
  }
}