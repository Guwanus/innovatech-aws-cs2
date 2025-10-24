# CS2-MA-NCA Phase 2: SOAR IaC + CI/CD

This repo contains Phase 2 deliverables: Terraform infra, GitHub Actions CI/CD, and SOAR app code (listener, engine, lambda actions).

## Quick start
1. Provision AWS credentials and add to GitHub secrets (see docs).
2. Run `terraform init` and `terraform apply` under `terraform/` (or use the `terraform-ci.yml` workflow).
3. Push app code to repo; GitHub Actions will build/push images and update ECS services.
4. Deploy Lambdas (via Terraform or AWS CLI).
5. Test by POSTing to listener endpoint.

## Notes
- All infra uses student-approved instance types: `db.t3.micro`, containers run on Fargate.
- Storage uses `gp3` where supported.