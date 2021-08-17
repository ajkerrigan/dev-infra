data "aws_iam_policy_document" "trust_me" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::000000000000:root"
      ]
    }
  }
}

data "aws_iam_policy_document" "trust_everybody" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::000000000000:root",
        "*",
      ]
    }
  }
}

resource "aws_iam_role" "trust_me" {
  name               = "trust_me"
  assume_role_policy = data.aws_iam_policy_document.trust_me.json
}

resource "aws_iam_role" "trust_everybody" {
  name               = "trust_everybody"
  assume_role_policy = data.aws_iam_policy_document.trust_everybody.json
}
