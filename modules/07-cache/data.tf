# Look up shared platform resources by tag/alias so this module stays
# independently plan/validate-able (no terraform_remote_state).

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

# Identity of the account running this layer — used to grant the account root
# full control over this layer's CMK.
data "aws_caller_identity" "current" {}

# Key policy for the cache CMK: the account root retains full administrative
# control. ElastiCache uses grants (created by the calling principal) to
# encrypt/decrypt with the key at rest, so no service statement is required.
data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowAccountRootFullAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}
