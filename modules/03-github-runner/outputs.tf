output "runner_instance_id" {
  description = "EC2 instance ID of the self-hosted GitHub runner."
  value       = module.runner.ec2_runner_instance_id
}

output "runner_role_arn" {
  description = "IAM role ARN of the runner instance."
  value       = module.runner.ec2_runner_role_arn
}
