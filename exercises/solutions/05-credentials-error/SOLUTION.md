# Solution 05: Credentials error

## Root cause
The provider block hard-coded `profile = "infra-experiments-typo"`, a profile that does not exist in `~/.aws/config` or `~/.aws/credentials`. The AWS provider looks the profile up while configuring itself, so planning fails before any resource is read.

It also explains why `AWS_PROFILE=default` did nothing: an explicit `profile` in the provider block takes precedence over the environment variable.

## Fix
Do not hard-code the profile. Make it an optional variable that defaults to `null`, so the provider uses the standard credential lookup (environment variables, `AWS_PROFILE`, or the default profile):

```hcl
variable "aws_profile" {
  type    = string
  default = null
}

provider "aws" {
  region  = "us-west-1"
  profile = var.aws_profile
}
```
Pass `-var aws_profile=name` only when you need a specific one.

## Why it matters
Account-specific names do not belong in shared configuration. They break for anyone whose machine is set up differently, including CI. Credentials should come from the environment, which is also what this repository's conventions require.

## Diagnosing it faster
- The words in the error (`shared config profile`) say the problem is a named profile, not a permission.
- `aws configure list-profiles` shows what exists.
- `TF_LOG=DEBUG terraform plan` logs the credential lookup, step by step.

## Note on automated checking
The exercise fails the same way anywhere because it fails before any network call, so `make check-exercises` can verify it. The solution can only be validated automatically, because a real plan needs real credentials.
