# 12-cloudfront

CloudFront distribution that serves the **static frontend (SPA)** — this is the
public UI entry point. Content comes from the `11-s3` bucket (S3 origin via OAC);
the EKS-hosted app behind the ALB is the **backend API**, reached separately.

- **WAF:** attached via `web_acl_id` to the CLOUDFRONT-scope Web ACL from `08-waf`
  (us-east-1). The public UI is WAF-protected at the edge.
- **TLS:** ACM certificate provisioned in us-east-1 for `var.ui_host`.
- **DNS:** Route53 alias `var.ui_host` -> the distribution.
- **SPA routing:** 403/404 from S3 return `/index.html` (200).

Domain inputs (`root_domain`, `ui_host`) are passed by the pipeline from
`HOSTED_ZONE` + `APP_SUBDOMAIN`. Applied by the `cloudfront` job in
`.github/workflows/create.yml` after `08-waf` and `11-s3`. The `deploy-frontend`
job then syncs `sample-app/frontend/` to S3 and invalidates this distribution.
