# 11-s3

Private S3 bucket that stores the **static frontend (SPA)** assets and serves as
the **CloudFront S3 origin** for `12-cloudfront` (read via Origin Access Control).
CloudFront access logs are written here as well.

- Bucket name: `<namespace>-<env>-frontend` (e.g. `eb-dev-frontend`).
- Public access fully blocked; encryption, versioning and lifecycle are
  compliance-profile aware (`tfvars/<env>.tfvars`).
- The `deploy-frontend` pipeline job runs `aws s3 sync sample-app/frontend/` into this
  bucket and then invalidates the CloudFront distribution.

Applied by the `s3` job in `.github/workflows/create.yml` (independent Terraform
root, own S3 backend). Consumed by `12-cloudfront` via `output.bucket_id`.
