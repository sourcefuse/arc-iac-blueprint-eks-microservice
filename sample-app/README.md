# Sample App

A **zero-dependency Node.js HTTP service** that proves the microservices EKS stack works end-to-end with no code of your own.

```
ALB → EKS Ingress → platform namespace → this pod → Aurora / Redis
```

Replace `index.js` with your real service whenever you are ready.

---

## What it returns

`GET /` → JSON welcome payload including the wired `DB_HOST` and `REDIS_HOST` env vars.
`GET /health` → `{ "status": "ok" }`.

## Test locally

```bash
cd sample-app
node index.js          # starts on :8080
curl http://localhost:8080/health
```

## Build and push to ECR

From the blueprint root (after the modules are applied). Outputs come from each module's
own directory:

```bash
ECR_URL=$(cd modules/05-ecr && terraform output -raw repository_url)
aws ecr get-login-password | docker login --username AWS --password-stdin "$ECR_URL"

docker build -t "$ECR_URL:latest" sample-app/
docker push "$ECR_URL:latest"
```

## Deploy to EKS (Helm chart, delivered by ArgoCD)

The app ships as a Helm chart under [`charts/sample-app/`](../charts/sample-app/)
(Deployment + Service + Ingress). **In the pipeline the app is deployed by
ArgoCD (GitOps), not by `helm` directly:** the `10-argocd` layer declares an
ArgoCD `Application` that points at this chart, and ArgoCD renders it and keeps
the cluster in sync (auto-sync + self-heal). The app appears as Application
`sample-app` in the ArgoCD UI. Deploy-time values — image, backing-service
endpoints, custom domain, ACM cert and WAF ARN — are passed as ArgoCD Helm
parameters (they come from Terraform outputs / ACM / WAF, so they are never
baked into the chart).

To install the same chart **by hand** for local testing (bypassing ArgoCD),
values go via `--set-string`:

```bash
# Point kubectl at the cluster
CLUSTER=$(cd modules/04-eks && terraform output -raw cluster_id)
aws eks update-kubeconfig --region us-east-1 --name "$CLUSTER"

DB=$(cd modules/06-aurora && terraform output -raw cluster_endpoint)
REDIS=$(cd modules/07-cache && terraform output -raw cluster_address)
WAF=$(cd modules/08-waf && terraform output -raw arn)

helm upgrade --install sample-app charts/sample-app \
  --namespace sample-app --create-namespace \
  --set-string image.repository="$ECR_URL" \
  --set-string image.tag=latest \
  --set-string env.dbHost="$DB" \
  --set-string env.redisHost="$REDIS" \
  --set-string ingress.wafArn="$WAF"
  # add --set-string ingress.certArn=<acm-arn> --set-string ingress.host=<fqdn>
  # for HTTPS on a custom domain; omit both to serve HTTP on the raw ALB DNS.

# Verify
kubectl get pods -n sample-app
kubectl logs -n sample-app -l app=sample-app

# The ingress provisions an ALB (via the AWS Load Balancer Controller). Get its URL:
kubectl get ingress sample-app -n sample-app \
  -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"

# Tear it back down
helm uninstall sample-app -n sample-app
```

## Order of operations

1. Apply the modules — creates KMS, network, EKS, addons, ECR, Aurora, Redis, WAF, ALB
2. Build + push image to ECR
3. Update kubeconfig
4. `helm upgrade --install` the chart (see above)
5. Verify pods are Running and `/health` returns 200

---

Built by **[SourceFuse](https://www.sourcefuse.com)**.
