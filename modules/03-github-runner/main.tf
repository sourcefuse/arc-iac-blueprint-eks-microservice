# Generates a standard tag map applied to all resources in this layer.
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.9"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    Layer             = "03-github-runner"
    ManagedBy         = "Terraform"
    ComplianceProfile = var.compliance_profile
  }
}

# Self-hosted GitHub Actions runner (single EC2) in a PRIVATE subnet of the
# platform VPC. Required because 04-eks uses a private-only API endpoint: the
# cluster-touching pipeline jobs (04-eks add-ons, deploy-sample, observability,
# argocd) run ON this runner so they can reach the private Kubernetes API.
module "runner" {
  # Published SourceFuse ARC module (the s3-acl-disabled fix is merged upstream).
  source  = "sourcefuse/arc-github-runner/aws"
  version = "0.2.10"

  namespace   = var.namespace
  environment = var.environment
  region      = var.region

  vpc_id                      = data.aws_vpc.this.id
  subnet_id                   = data.aws_subnets.private.ids[0]
  associate_public_ip_address = false
  instance_type               = var.instance_type

  # The module's default AMI (Ubuntu 18.04) is EOL and no longer published, so
  # its lookup fails — pin a current Ubuntu 22.04 AMI resolved in data.tf.
  ami = {
    id       = data.aws_ami.ubuntu.id
    owner_id = "099720109477"
  }

  github_token  = var.github_token
  github_owner  = var.github_owner
  repos_or_orgs = var.repos_or_orgs
  runner_labels = var.runner_labels
  runner_name   = "${local.name_prefix}-runner"
}
