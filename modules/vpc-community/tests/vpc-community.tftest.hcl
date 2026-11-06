# Run with: terraform -chdir=modules/vpc-community test
# Mirrors modules/vpc/tests so both implementations are held to the same behaviour.
# Uses a mocked AWS provider, so no credentials are needed and nothing is created.

mock_provider "aws" {
  override_data {
    target = data.aws_availability_zones.available
    values = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
    }
  }

  # The mock returns random text for policy JSON, which the IAM role rejects.
  override_data {
    target = module.vpc.data.aws_iam_policy_document.flow_log_cloudwatch_assume_role[0]
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = module.vpc.data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0]
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  name = "test"
}

run "defaults_give_a_cheap_two_az_network_without_nat" {
  command = plan

  assert {
    condition     = length(module.vpc.public_subnets_cidr_blocks) == 2 && length(module.vpc.private_subnets_cidr_blocks) == 2
    error_message = "Defaults should create one public and one private subnet in each of two AZs."
  }

  assert {
    condition     = length(module.vpc.natgw_ids) == 0 && length(output.nat_public_ips) == 0
    error_message = "NAT gateways cost money, so they must be off by default."
  }

  assert {
    condition     = module.vpc.vpc_enable_dns_support && module.vpc.vpc_enable_dns_hostnames
    error_message = "EKS requires DNS support and DNS hostnames."
  }

  assert {
    condition     = alltrue([for subnet in module.vpc.public_subnet_objects : !subnet.map_public_ip_on_launch])
    error_message = "Public subnets should not hand out public IPs automatically."
  }

  assert {
    condition     = length(module.endpoints) == 1
    error_message = "The S3 gateway endpoint should be on by default."
  }
}

run "every_subnet_gets_its_own_address_range" {
  command = plan

  variables {
    az_count = 4
  }

  assert {
    condition = length(distinct(concat(
      module.vpc.public_subnets_cidr_blocks,
      module.vpc.private_subnets_cidr_blocks,
    ))) == 8
    error_message = "Public and private subnets across four AZs must not share a CIDR block."
  }
}

run "private_subnets_are_larger_than_public_ones" {
  command = plan

  assert {
    condition     = module.vpc.private_subnets_cidr_blocks[0] == "10.0.0.0/20"
    error_message = "First private subnet should be 10.0.0.0/20."
  }

  assert {
    condition     = module.vpc.public_subnets_cidr_blocks[0] == "10.0.240.0/24"
    error_message = "First public subnet should be 10.0.240.0/24."
  }
}

run "single_nat_gateway_is_shared_by_every_private_subnet" {
  command = plan

  variables {
    enable_nat_gateway = true
    single_nat_gateway = true
  }

  assert {
    condition     = length(module.vpc.natgw_ids) == 1
    error_message = "A single NAT gateway should be created."
  }
}

run "per_az_nat_creates_one_gateway_per_zone" {
  command = plan

  variables {
    enable_nat_gateway = true
    single_nat_gateway = false
    az_count           = 3
  }

  assert {
    condition     = length(module.vpc.natgw_ids) == 3
    error_message = "One NAT gateway per AZ expected."
  }
}

run "eks_clusters_add_load_balancer_discovery_tags" {
  command = plan

  variables {
    eks_cluster_names = ["lab"]
  }

  assert {
    condition = (
      module.vpc.public_subnet_objects[0].tags["kubernetes.io/role/elb"] == "1" &&
      module.vpc.public_subnet_objects[0].tags["kubernetes.io/cluster/lab"] == "shared"
    )
    error_message = "Public subnets need the elb role tag and the cluster tag."
  }

  assert {
    condition     = module.vpc.private_subnet_objects[0].tags["kubernetes.io/role/internal-elb"] == "1"
    error_message = "Private subnets need the internal-elb role tag."
  }
}

run "plain_ec2_use_has_no_kubernetes_tags" {
  command = plan

  assert {
    condition     = !contains(keys(module.vpc.private_subnet_objects[0].tags), "kubernetes.io/role/internal-elb")
    error_message = "Kubernetes tags should only appear when eks_cluster_names is set."
  }
}

run "flow_logs_and_s3_endpoint_can_be_disabled" {
  command = plan

  variables {
    enable_flow_logs           = false
    enable_s3_gateway_endpoint = false
  }

  assert {
    condition     = module.vpc.vpc_flow_log_id == "" || module.vpc.vpc_flow_log_id == null
    error_message = "Flow logs should disappear when switched off."
  }

  assert {
    condition     = length(module.endpoints) == 0
    error_message = "The S3 endpoint should disappear when switched off."
  }
}

run "rejects_a_cidr_that_is_not_a_slash_16" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/24"
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_a_single_az" {
  command = plan

  variables {
    az_count = 1
  }

  expect_failures = [var.az_count]
}
