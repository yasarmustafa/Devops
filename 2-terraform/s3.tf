resource "aws_s3_bucket" "main" {
  bucket = "mustafayasar02" # benzersiz bir isim varilmesi gerekiyor. (a-z,0-9,-)

  tags = {
    Name        = "mustafayasar01"
    Environment = "test"
  }
}