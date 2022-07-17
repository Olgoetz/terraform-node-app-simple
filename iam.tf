resource "aws_iam_instance_profile" "node" {
  name = "${local.prefix}InstanceProfile-${local.random_id}"
  role = aws_iam_role.node.name
}

resource "aws_iam_role" "node" {
  name = "${local.prefix}InstanceRole-${local.random_id}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "node" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:instance/*"]
  }
}

resource "aws_iam_role_policy" "node" {
  name   = "${local.prefix}InstanceRolePolicy-${local.random_id}"
  role   = aws_iam_role.node.name
  policy = data.aws_iam_policy_document.node.json
}