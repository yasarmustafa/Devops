output "ami" {
  value = aws_instance.main.ami
}

output "instance_id" {
  value = aws_instance.main.id
}

output "instance_ip" {
  value = aws_instance.main.private_ip
}

output "instance_tags" {
  value = aws_instance.main.tags_all
}