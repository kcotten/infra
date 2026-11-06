# Run with: terraform -chdir=modules/vpc test
# Uses a mocked AWS provider, so no credentials are needed and nothing is created.

mock_provider "aws" {
  override_data {
    target = data.aws_availability_zones.available
    values = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
    }
  }

  override_data {
    target = data.aws_region.current
    values = {
      region = "us-east-1"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.flow_logs_assume_role
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.flow_logs_write
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
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 2
    error_message = "Defaults should create one public and one private subnet in each of two AZs."
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 0 && length(aws_eip.nat) == 0
    error_message = "NAT gateways cost money, so they must be off by default."
  }

  assert {
    condition     = aws_vpc.main.enable_dns_support && aws_vpc.main.enable_dns_hostnames
    error_message = "EKS requires DNS support and DNS hostnames."
  }

  assert {
    condition     = alltrue([for subnet in aws_subnet.public : !subnet.map_public_ip_on_launch])
    error_message = "Public subnets should not hand out public IPs automatically."
  }

  assert {
    condition     = aws_default_security_group.default.tags["Name"] == "test-default-deny"
    error_message = "The default security group should be managed (and so stripped of its rules)."
  }

  assert {
    condition     = length(aws_flow_log.main) == 1
    error_message = "Flow logs should be on by default."
  }
}

run "every_subnet_gets_its_own_address_range" {
  command = plan

  variables {
    az_count = 4
  }

  assert {
    condition = length(distinct(concat(
      [for subnet in aws_subnet.public : subnet.cidr_block],
      [for subnet in aws_subnet.private : subnet.cidr_block],
    ))) == 8
    error_message = "Public and private subnets across four AZs must not share a CIDR block."
  }
}

run "private_subnets_are_larger_than_public_ones" {
  command = plan

  assert {
    condition     = aws_subnet.private["us-east-1a"].cidr_block == "10.0.0.0/20"
    error_message = "First private subnet should be 10.0.0.0/20."
  }

  assert {
    condition     = aws_subnet.public["us-east-1a"].cidr_block == "10.0.240.0/24"
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
    condition     = length(aws_nat_gateway.main) == 1
    error_message = "A single NAT gateway should be created."
  }

  assert {
    condition     = length(aws_route.private_nat) == 2
    error_message = "Every private route table should route through NAT."
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
    condition     = length(aws_nat_gateway.main) == 3
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
      aws_subnet.public["us-east-1a"].tags["kubernetes.io/role/elb"] == "1" &&
      aws_subnet.public["us-east-1a"].tags["kubernetes.io/cluster/lab"] == "shared"
    )
    error_message = "Public subnets need the elb role tag and the cluster tag."
  }

  assert {
    condition     = aws_subnet.private["us-east-1a"].tags["kubernetes.io/role/internal-elb"] == "1"
    error_message = "Private subnets need the internal-elb role tag."
  }
}

run "plain_ec2_use_has_no_kubernetes_tags" {
  command = plan

  assert {
    condition     = !contains(keys(aws_subnet.private["us-east-1a"].tags), "kubernetes.io/role/internal-elb")
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
    condition     = length(aws_flow_log.main) == 0 && length(aws_vpc_endpoint.s3) == 0
    error_message = "Optional features should disappear when switched off."
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
