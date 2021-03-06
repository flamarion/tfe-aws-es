# Role, Policies and Instance Profiles
resource "aws_iam_role" "tfe_iam_role" {
  name               = "${var.owner}-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "tfe_instance_profile" {
  name = "${var.owner}-tfe-es-profile"
  role = aws_iam_role.tfe_iam_role.name
}

data "aws_iam_policy_document" "ptfe" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.tfe_s3.id}",
      "arn:aws:s3:::${aws_s3_bucket.tfe_s3.id}/*",
    ]

    actions = [
      "s3:*",
    ]
  }
}

resource "aws_iam_role_policy" "tfe_policy" {
  name   = "${var.owner}-iam-role-policy"
  role   = aws_iam_role.tfe_iam_role.name
  policy = data.aws_iam_policy_document.ptfe.json
}



# Script to bootstrap TFE Installation
data "template_file" "tfe_config" {
  template = file("${path.module}/templates/tfe_config.sh.tpl")

  vars = {
    admin_password                  = random_password.admin_password.result
    rel_seq                         = var.rel_seq
    tfe_ha                          = var.tfe_ha
    enc_password                    = random_password.enc_password.result
    user_token                      = random_id.user_token.hex
    install_id                      = random_id.install_id.hex
    root_secret                     = random_id.root_secret.hex
    archivist_token                 = random_id.archivist_token.hex
    cookie_hash                     = random_id.cookie_hash.hex
    internal_api_token              = random_id.internal_api_token.hex
    registry_session_encryption_key = random_id.registry_session_encryption_key.hex
    registry_session_secret_key     = random_id.registry_session_secret_key.hex
    lb_fqdn                         = aws_route53_record.alias_record.fqdn
    s3_bucket_name                  = split(".", aws_s3_bucket.tfe_s3.bucket_domain_name)[0]
    s3_region                       = aws_s3_bucket.tfe_s3.region
    db_name                         = module.pgsql_cluster.db_name
    db_user                         = module.pgsql_cluster.db_user
    db_pass                         = module.pgsql_cluster.db_pass
    db_port                         = module.pgsql_cluster.port
    db_host                         = module.pgsql_cluster.endpoint
    redis_host                      = aws_elasticache_replication_group.redis_cluster.primary_endpoint_address
    redis_port                      = aws_elasticache_replication_group.redis_cluster.port
    redis_pass                      = aws_elasticache_replication_group.redis_cluster.auth_token
  }
}

# Launch configuration 
resource "aws_launch_configuration" "tfe_instances" {
  name                        = "${var.owner}-tfe-es-lc-${var.bg}"
  image_id                    = "ami-0ac4552d876835070" # Image with HA license
  instance_type               = "m5.large"
  iam_instance_profile        = aws_iam_instance_profile.tfe_instance_profile.name
  key_name                    = aws_key_pair.ssh_key.key_name
  security_groups             = [module.tfe_instances_sg.sg_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.tfe_config.rendered
  root_block_device {
    volume_size = 100
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "tfe_asg" {
  name                 = "${var.owner}-tfe-es-asg"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.public_subnets_id
  launch_configuration = aws_launch_configuration.tfe_instances.name
  target_group_arns = [
    aws_lb_target_group.tg_https.arn
    # aws_lb_target_group.tg_replicated.arn
  ]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.owner}-asg-instances"
    propagate_at_launch = true
  }
}
