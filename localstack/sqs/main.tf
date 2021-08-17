resource "aws_kms_key" "sqs" {
  description = "encrypt sqs messages"
}

resource "aws_sqs_queue" "encrypted" {
  name              = "demo-encrypted"
  kms_master_key_id = aws_kms_key.sqs.arn
}

resource "aws_sqs_queue" "unencrypted" {
  name = "demo-unencrypted"
}
