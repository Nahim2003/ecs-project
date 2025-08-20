# Threat Modelling Tool (ECS Deployment)

This project deploys a simple **Node.js/Express app** (`Threat Modelling Tool`) to **AWS ECS Fargate** using **Terraform** and **Docker**.
The infrastructure is fully automated and includes networking, load balancing, TLS, and DNS.

---

## 🚀 Features

* **Containerised app** with Docker
* **ECS Fargate** deployment (serverless containers)
* **Application Load Balancer (ALB)** with HTTPS via ACM
* **Custom domain** via Route 53 → [https://tm.nahimtm.xyz](https://tm.nahimtm.xyz)
* **CloudWatch logging** for container output
* **Infrastructure as Code** with Terraform

---

## 🏗 Architecture

```
Route53 (tm.nahimtm.xyz)
         |
         v
Application Load Balancer (HTTPS :443)
         |
         v
   ECS Service (Fargate)
         |
         v
   Container (Node.js app on :3000)
```

* **VPC** with public + private subnets
* **ALB** in public subnets
* **ECS tasks** running in private subnets
* **CloudWatch** for monitoring

---

## 📷 Screenshots

* ✅ **App live**:
  ![App running](screenshots/app-live.png)

* ✅ **ECS Service running**:
  ![ECS service](screenshots/ecs-service.png)

* ✅ **CloudWatch logs**:
  ![Logs](screenshots/cloudwatch-logs.png)

* ✅ **HTTPS via Route 53 + ACM**:
  ![TLS](screenshots/https-cert.png)

---
