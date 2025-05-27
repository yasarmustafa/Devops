resource "aws_s3_bucket" "main" {
  bucket = "mustafayasar01" # benzersiz bir isim varilmesi gerekiyor. (a-z,0-9,-)

  tags = {
    Name        = "mustafayasar101"
    Environment = "test"
  }
}