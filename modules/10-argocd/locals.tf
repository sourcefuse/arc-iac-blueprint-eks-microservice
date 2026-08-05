locals {
  name_prefix = "${var.namespace}-${var.environment}"
  tags        = module.tags.tags

  # Split "<repo>:<tag>". ECR repository URLs contain no colon, so the (single)
  # colon separates the tag; default to "latest" if only a repo was supplied.
  image_parts    = split(":", var.app_image)
  app_image_repo = local.image_parts[0]
  app_image_tag  = length(local.image_parts) > 1 ? local.image_parts[1] : "latest"

  # Only declare the Application (and its repo credential) once an image exists —
  # the control-plane apply (argocd job) runs with app_image="" and creates
  # nothing here; the app apply (deploy-sample) supplies the image and creates it.
  create_sample_app = var.enable_argocd && var.enable_sample_app && var.app_image != ""

  # Helm parameters mirror the chart's values.yaml knobs (see charts/sample-app).
  # ingress.certArn/host are only set when a cert was resolved (else the chart
  # serves plain HTTP), matching the chart's conditional ingress template.
  sample_app_params = concat(
    [
      { name = "image.repository", value = local.app_image_repo },
      { name = "image.tag", value = local.app_image_tag },
      { name = "env.dbHost", value = var.app_db_host },
      { name = "env.redisHost", value = var.app_redis_host },
    ],
    var.app_cert_arn != "" ? [
      { name = "ingress.certArn", value = var.app_cert_arn },
      { name = "ingress.host", value = var.app_host },
    ] : []
  )
}
