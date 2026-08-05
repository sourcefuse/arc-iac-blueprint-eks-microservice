namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

# root_domain and ui_host are supplied by the pipeline (TF_VAR_root_domain /
# TF_VAR_ui_host) from HOSTED_ZONE + APP_SUBDOMAIN so the alias, ACM cert and
# Route53 record match the deployed frontend URL.
price_class = "PriceClass_100"
