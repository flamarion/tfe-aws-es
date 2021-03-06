# POC SG
# module "poc_sg" {
#   source      = "github.com/flamarion/terraform-aws-sg?ref=v0.0.5"
#   name        = "${var.owner}-poc-tfe-es-sg"
#   description = "Security Group"
#   vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
#   sg_tags = {
#     Name = "${var.owner}-poc-tfe-es-sg"
#   }

#   sg_rules_cidr = {
#     allow_all_in = {
#       description       = "Allow access from TFE Instances"
#       type              = "ingress"
#       cidr_blocks       = ["0.0.0.0/0"]
#       from_port         = 0
#       to_port           = 0
#       protocol          = "-1"
#       security_group_id = module.poc_sg.sg_id
#     },
#     allow_all_out = {
#       description       = "Allow all outbound traffic"
#       type              = "egress"
#       cidr_blocks       = ["0.0.0.0/0"]
#       from_port         = 0
#       to_port           = 0
#       protocol          = "-1"
#       security_group_id = module.poc_sg.sg_id
#     }
#   }
# }


# # DB Cluster Security Group
module "db_sg" {
  source      = "github.com/flamarion/terraform-aws-sg?ref=v0.0.5"
  name        = "${var.owner}-tfe-es-db-sg"
  description = "Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_tags = {
    Name = "${var.owner}-tfe-es-db-sg"
  }

  sg_rules_cidr = {
    postgres = {
      description       = "Allow access from TFE Instances"
      type              = "ingress"
      cidr_blocks       = data.terraform_remote_state.vpc.outputs.public_subnets
      from_port         = module.pgsql_cluster.port
      to_port           = module.pgsql_cluster.port
      protocol          = "tcp"
      security_group_id = module.db_sg.sg_id
    },
    outbound = {
      description       = "Allow all outbound traffic"
      type              = "egress"
      cidr_blocks       = ["0.0.0.0/0"]
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      security_group_id = module.db_sg.sg_id
    }
  }
}

# # Redis Cluster Security Group
module "redis_sg" {
  source      = "github.com/flamarion/terraform-aws-sg?ref=v0.0.5"
  name        = "${var.owner}-tfe-es-redis-sg"
  description = "Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_tags = {
    Name = "${var.owner}-tfe-es-redis-sg"
  }

  sg_rules_cidr = {
    postgres = {
      description       = "Allow access from TFE Instances"
      type              = "ingress"
      cidr_blocks       = data.terraform_remote_state.vpc.outputs.public_subnets
      from_port         = var.redis_port
      to_port           = var.redis_port
      protocol          = "tcp"
      security_group_id = module.redis_sg.sg_id
    },
    outbound = {
      description       = "Allow all outbound traffic"
      type              = "egress"
      cidr_blocks       = ["0.0.0.0/0"]
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      security_group_id = module.redis_sg.sg_id
    }
  }
}

# Load Balancer Security Group
module "lb_sg" {
  source      = "github.com/flamarion/terraform-aws-sg?ref=v0.0.5"
  name        = "${var.owner}-tfe-es-lb-sg"
  description = "Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_tags = {
    Name = "${var.owner}-tfe-es-lb-sg"
  }

  sg_rules_cidr = {
    https = {
      description       = "Terraform Cloud application via HTTPS"
      type              = "ingress"
      cidr_blocks       = ["0.0.0.0/0"]
      from_port         = var.https_port
      to_port           = var.https_port
      protocol          = "tcp"
      security_group_id = module.lb_sg.sg_id
    },
    outbound = {
      description       = "Allow all outbound"
      type              = "egress"
      cidr_blocks       = ["0.0.0.0/0"]
      to_port           = 0
      protocol          = "-1"
      from_port         = 0
      security_group_id = module.lb_sg.sg_id
    }
  }
}


# TFE Instances Security Group
module "tfe_instances_sg" {
  source      = "github.com/flamarion/terraform-aws-sg?ref=v0.0.5"
  name        = "${var.owner}-tfe-es-instance-sg"
  description = "Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_tags = {
    Name = "${var.owner}-tfe-es-instance-sg"
  }
  sg_rules_sgid = {
    https = {
      description              = "Terraform Cloud application via HTTPS"
      type                     = "ingress"
      from_port                = var.https_port
      to_port                  = var.https_port
      source_security_group_id = module.lb_sg.sg_id
      protocol                 = "tcp"
      security_group_id        = module.tfe_instances_sg.sg_id
    }
  }

  sg_rules_cidr = {
    ssh = {
      description       = "Allow SSH"
      type              = "ingress"
      cidr_blocks       = ["0.0.0.0/0"]
      from_port         = "22"
      to_port           = "22"
      protocol          = "tcp"
      security_group_id = module.tfe_instances_sg.sg_id
    },
    vault = {
      description       = "Vault"
      type              = "ingress"
      cidr_blocks       = concat(data.terraform_remote_state.vpc.outputs.public_subnets, data.terraform_remote_state.vpc.outputs.cache_subnets, data.terraform_remote_state.vpc.outputs.database_subnets)
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      security_group_id = module.tfe_instances_sg.sg_id
    },
    outbound = {
      description       = "Allow all outbound traffic"
      type              = "egress"
      cidr_blocks       = ["0.0.0.0/0"]
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      security_group_id = module.tfe_instances_sg.sg_id
    }
  }
}
