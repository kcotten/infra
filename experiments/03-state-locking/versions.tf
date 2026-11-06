terraform {
  required_version = ">= 1.10"

  # Bucket and region come from a backend config file; the key is set per experiment.
  backend "s3" {}
}
