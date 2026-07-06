# devop-assignment-Tripare-AI
Tripare AI assignment 


# Hotel Platform Infrastructure and Database Assignment

This repository contains:

- Terraform infrastructure for Internet → ALB → ECS/Fargate → RDS
- Separate Terraform environments for dev and prod
- GitHub Actions Terraform plan workflow
- Local PostgreSQL database using Docker Compose
- SQL migrations and seed data
- Backup and restore scripts

---

## Architecture

Traffic flow:

Internet → Public ALB → ECS/Fargate private tasks → Private RDS PostgreSQL

Security design:

- ALB is public and accepts HTTP traffic on port 80.
- ECS/Fargate tasks are deployed in private subnets.
- RDS is deployed in private database subnets.
- RDS security group allows PostgreSQL traffic only from the ECS/Fargate security group.
- RDS is not publicly accessible.

---

## Terraform Structure

```text
infra/
  modules/
    network/
    ecs/
    rds/
  envs/
    dev/
    prod/
