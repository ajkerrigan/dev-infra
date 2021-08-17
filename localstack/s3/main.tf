variable "tags" {
  type = map
  default = {
    Creator = "aj"
  }
}

resource "aws_s3_bucket" "untagged" {
  bucket = "untagged-bucket"
}

resource "aws_s3_bucket" "tagged" {
  bucket = "tagged-bucket"
  tags = {
    Creator = "aj"
    Name = "tagged-bucket"
  }
}
