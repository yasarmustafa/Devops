# output "ami" {
#   value = aws_instance.main.ami
# }

# output "instance_id" {
#   value = aws_instance.main.id
# }

# output "instance_ip" {
#   value = aws_instance.main.private_ip
# }

# output "instance_tags" {
#   value = aws_instance.main.tags_all
# }
# -------------------------------------------
# output "instance_ami" {
#   value = aws_instance.main.*.ami
# }

# output "instance_ids" {
#   value = aws_instance.main.*.id
# }

# output "instance_ips" {
#   value = aws_instance.main.*.private_ip
# }

# output "instance_tags" {
#   value = aws_instance.main.*.tags_all
# }
# -----------------------------------------------
output "instance_ami" {
  value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.ami
  }
}

output "instance_ids" {
  value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.id
  }
}

output "instance_ips" {
  value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.private_ip
  }
}

output "instance_tags" {
  value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.tags_all
  }

}
output "uppercased_names" {
  value = [for name in var.names : upper(name)] # for dongüsü değişkenleri sıra ile çekerek fonksiyonu uyguluyor.
}

output "region_names" {
  value = [for region, name in var.region_map : "${region} is in ${name}"]
}

output "even_numbers" {
  value = [for num in var.numbers : num if num % 2 == 0]
}
output "us_regions" {
  value = { for region, name in var.region_map : region => name if startswith(region, "us-") }
}
