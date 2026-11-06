# vpc-community

The same VPC as [`modules/vpc`](../vpc/README.md), built on the community [`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module (pinned to 6.7.3). It has identical inputs and outputs, so the two are interchangeable and the differences between them are easy to see.

## Why have both

| | `modules/vpc` (hand-written) | `modules/vpc-community` (wrapper) |
| --- | --- | --- |
| Code you maintain | About 250 lines, 18 resource blocks | About 90 lines, two module calls, mostly mapping inputs |
| Understanding | Every resource and route is visible and explained | Behaviour lives in a large external module with hundreds of variables |
| Subnet CIDRs and AZs | Computed inside the module | The community module expects them as lists, so this wrapper computes them |
| Private route tables | Always one per AZ | One per NAT gateway, so a **single NAT shares one table** across all private subnets |
| Flow logs | Explicit log group, IAM role and policy | Three flags; the community module creates the same pieces |
| S3 gateway endpoint | One resource | Separate `vpc-endpoints` submodule, with a lookup of the service |
| Upgrades | You decide what changes | Version bumps may rename inputs or resources (6.x already differs from 5.x) |
| Extras you could enable | Only what you write | IPv6, database and intra subnets, VPN gateway, NACLs, secondary CIDRs and more |

Use the hand-written module to learn how the pieces fit. Use the community wrapper when you want the long tail of features without writing them, and accept the dependency.

## Differences in behaviour

- `private_route_table_ids` has one entry per AZ, except when `enable_nat_gateway` and `single_nat_gateway` are both true, when it has one shared entry.
- Resource names and tags follow the community module's conventions, so they are close to, but not identical to, `modules/vpc`.
- The wrapper pins an exact module version. Bump it deliberately and run the tests.

See [`modules/vpc`](../vpc/README.md) for the subnet layout, cost notes and usage examples; they apply here unchanged.

## Tests

The tests mirror `modules/vpc/tests` and mock the AWS provider, so they need no credentials and create nothing.

```bash
terraform -chdir=modules/vpc-community init
terraform -chdir=modules/vpc-community test
```

## Not covered yet

- Applying this module to a real account: it is validated and unit-tested only.
- Verifying that the two modules produce equivalent plans against real AWS. The tests check intent, not a resource-by-resource diff.
