# devops-assignment-Tripare-AI
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
```
--- 
#Query Optimised

SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;

---

#Index choice explaination

The main query filters by city and created_at, then groups by org_id and status while calculating SUM(amount).

Index used:

CREATE INDEX idx_hotel_bookings_city_created_org_status
ON hotel_bookings (city, created_at, org_id, status)
INCLUDE (amount);

Reason:
- city is used as an equality filter.
- created_at is used as a range filter for the last 30 days.
- org_id and status are used in GROUP BY.
- amount is included to help PostgreSQL read the aggregate value from the index where possible.
