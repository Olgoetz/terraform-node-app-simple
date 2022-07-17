# Security group
#tfsec:ignore:aws-vpc-no-public-ingress-sgr
#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group" "ec2" {
  name        = "${local.prefix}SG-${random_id.this.id}"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow client traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow server management"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow installation of software"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create a ssh key
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2" {
  key_name   = "${local.prefix}Key"
  public_key = tls_private_key.ec2.public_key_openssh
}

# Get ami id
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create instance
#tfsec:ignore:aws-ec2-enable-at-rest-encryption
resource "aws_instance" "node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.nano"
  key_name               = aws_key_pair.ec2.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = templatefile("${path.module}/sources/user_data.tpl.sh", { aws_region = data.aws_region.this.name })
  iam_instance_profile   = aws_iam_instance_profile.node.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${local.prefix}Instance"
  }
}

resource "null_resource" "wait_for_cloudinit" {
  depends_on = [aws_instance.node]
  provisioner "local-exec" {
    command = <<-EOF
    #!/bin/bash
    expected="true"
    # Init call
    command="aws ec2 describe-tags --filters Name=resource-id,Values=${aws_instance.node.id} Name=key,Values=cloudinit-complete --output text --query Tags[0].Value"
    tag=$($command)
    while [[ "$tag" != "$expected" ]] ; do
      tag=$($command)
    done
    EOF
  }
}