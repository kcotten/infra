# Costs

The project's budget is **US$5 a month** (NFR-004). Almost everything here costs nothing, and this page says why, so you can tell when something you add would not.

Prices change and differ by region. Figures below are either measured from this account or taken from AWS's own pages, and anything else is described in words. Check the linked pricing pages before relying on a number.

## What exists today
| Item | Cost | Why |
|------|------|-----|
| State bucket (`infra-experiments-tfstate-...`) | Well under one cent a month | Measured on 2026-11-05: 3 live objects, 18 versions in total, about 15 KB. S3 Standard storage is charged per gigabyte-month, so 15 KB rounds to nothing. Old versions expire after 90 days. |
| State requests | Cents at most | S3 charges per thousand requests (PUT-type requests are $0.005 per thousand in the examples on [AWS's S3 pricing page](https://aws.amazon.com/s3/pricing/); check the page for your region). A plan or apply makes a handful of requests. |
| Budget `infra-experiments-monthly` | Free | AWS does not charge to [monitor and get notified about budgets](https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/). Charges apply only to action-enabled budgets beyond the first two, and this budget has no actions. |
| Experiments, exercises, module (`local`, `random`, `terraform_data`) | Free | They run on your machine and create no cloud resources. |
| IAM, `aws_caller_identity` lookups | Free | |
| Exercise 06's SSM parameter (only while it exists) | Free | A [standard-tier Parameter Store parameter has no additional charge](https://aws.amazon.com/systems-manager/pricing/). Advanced-tier parameters are billed, so the exercise pins `tier = "Standard"`. Destroy it when finished. |

## The budget measures the whole account
`infra-experiments-monthly` watches **all** spend in AWS account `538632037025`, not only this project. You also have a separate US$100 budget. Anything else running in the account counts towards the US$5, so the alert may fire for reasons that have nothing to do with this repository.

Alerts go to the configured email at 50%, 80% and 100% of **actual** spend, plus when the **forecast** passes 100%.

## Not yet verified
The alert emails have not been seen to arrive. To test, temporarily lower `monthly_budget_usd` in `bootstrap/terraform.tfvars` to something tiny, apply, and wait for AWS's next budget evaluation (AWS evaluates several times a day; it is not instant). Restore the value afterwards. Do this deliberately; it changes a live resource.

## Before adding a cloud resource to an experiment
1. Look up its price on the service's AWS pricing page and write it in the experiment's README under **Cost**.
2. Prefer a free alternative: a local provider, or a free-tier resource.
3. Tag it (the `default_tags` in the AWS provider do this for you).
4. Destroy it when you finish: `make destroy DIR=experiments/<name>`.

### Things that quietly cost money
These are the usual surprises when learning with Terraform. None is used here today.
- Anything that runs continuously: virtual machines, databases, NAT gateways, load balancers.
- Resources that cost while idle: unattached public IP addresses, provisioned-capacity tables.
- KMS keys, which charge a monthly fee per key (the reason the state bucket uses free SSE-S3 encryption instead).
- Logs and data transfer, which grow without anyone noticing.

## Checking your real spend
Use the AWS Billing console or Cost Explorer in the web console. Avoid calling the Cost Explorer API from scripts, because AWS charges per API request.
