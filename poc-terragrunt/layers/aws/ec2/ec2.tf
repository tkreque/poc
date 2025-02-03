data "aws_ami" "ec2" {
  most_recent = var.configs.env_vars.ec2.ami.most_recent
  owners      = var.configs.env_vars.ec2.ami.owners
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_default_tags" "aws_tags" {}

resource "aws_instance" "ec2" {
  for_each = { for index, ec2 in var.configs.env_vars.ec2 : ec2.name => ec2 if lookup(ec2, "name", null) != null }

  ami                         = data.aws_ami.ec2.image_id
  instance_type               = each.value.type
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = each.value.public_ip
  subnet_id                   = var.vpc_subnets[random_integer.ec2.result]

  vpc_security_group_ids = concat(
    [aws_security_group.ec2[each.key].id],
    var.rds_security_group_ids
  )

  user_data = templatefile("${path.module}/templates/user_data.tpl",
    {
      project_name      = var.configs.project_name
      ec2_name          = "${var.configs.ec2_name_prefix}-${each.key}"
      aws_profile_name  = var.configs.account_profile
      aws_region        = var.configs.aws_region
      stack             = var.configs.env_vars.stack
      mysql_url         = "https://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm"
      mysql_gpg_key_url = "https://repo.mysql.com/RPM-GPG-KEY-mysql-2022"
  })

  root_block_device {
    volume_size           = each.value.storage.size
    volume_type           = each.value.storage.type
    delete_on_termination = each.value.storage.delete_on_termination
    encrypted             = true
    kms_key_id            = aws_kms_key.ec2.arn
    tags = merge(
      data.aws_default_tags.aws_tags.tags,
      {
        Name = "${var.configs.ec2_name_prefix}-${each.key}",
      }
    )
  }

  tags = merge(
    data.aws_default_tags.aws_tags.tags,
    {
      Name = "${var.configs.ec2_name_prefix}-${each.key}",
      App = "${var.configs.ec2_name_prefix}-${each.key}"
    }
  )
}
