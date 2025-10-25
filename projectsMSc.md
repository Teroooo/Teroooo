# 🎓 IST MSc Projects  


## 📌 Table of Contents  

| No. | Project | Course / Context |
| ---: | --- | --- |
| 1 | [🚀 AGISIT - CHAT APP)]() | Management and Administration of It Infrastructures and Services |

# 💬 AGISIT Chat

<table align="center">
  <tr>
    <td><img width="1919" height="866" alt="Captura de ecrã 2025-10-24 214044" src="https://github.com/user-attachments/assets/af171680-d827-4ad1-9dc4-783a15f2e751" /></td>
  </tr>
  <tr>
    <td align="center"><strong>Login</strong></td>
  </tr>
  <tr>
    <td><img width="1919" height="870" alt="Captura de ecrã 2025-10-24 214105" src="https://github.com/user-attachments/assets/fd816183-20e8-4c3b-90b6-fa74f02edd73" /></td>
  </tr>
  <tr>
    <td align="center"><strong>UI</strong></td>
  </tr>
  <tr>
    <td><img width="1892" height="789" alt="Captura de ecrã 2025-10-24 214314" src="https://github.com/user-attachments/assets/77dfcf7f-912c-4b6b-b7fc-aa3573dc8c07" /></td>
  </tr>
  <tr>
    <td align="center"><strong>Grafana Dashboard</strong></td>
  </tr>
</table>

<p align="center">
  <a href="https://www.youtube.com/watch?v=uqSPkXvHev0" target="_blank">📹 Demo Video</a> •
  <a href="https://gitlab.com/username/agisit-chat" target="_blank">🔗 GitLab Repository</a>
</p>

<details>
<summary style="display: flex; justify-items:center;">About this project</summary>

<hr>

## ⚡ Features

- 🔹 **Real-time messaging** with WebSockets (Socket.io)
- 🔹 **User authentication** with JWT tokens
- 🔹 **Direct & group chats** with contact management
- 🔹 **Microservices architecture** (auth-users, contacts, messages, groups)
- 🔹 **Full observability** with Prometheus & Grafana dashboards
- 🔹 **CI/CD pipeline** with GitLab CI for automated deployments
- 🔹 **Infrastructure as Code** using Ansible & Terraform

## 🛠 Tech Stack

**Frontend:** HTML, CSS, JavaScript

**Backend:** Node.js, Express.js, Socket.io

**Database:** PostgreSQL (one per microservice)

**Orchestration:** Kubernetes (1 master + 3 workers)

**Monitoring:** Prometheus, Grafana

**CI/CD:** GitLab CI/CD, Kaniko, Docker Hub

**Infrastructure:** Google Cloud Platform, Ansible, Terraform

## 📊 Architecture

Microservices-based architecture deployed on self-hosted Kubernetes cluster:
- **Frontend** - Web interface (ingress point)
- **Auth-Users** - Authentication & user management
- **Contacts** - Contact list management
- **Messages** - Direct messaging service
- **Groups** - Group chat management
- **PostgreSQL** - Separate database per service
- **Prometheus + Grafana** - Real-time monitoring & metrics

## 📈 Performance

Evaluated with ApacheBench (1000 requests, 10 concurrent clients):
- **Frontend:** 116.8 req/s, 85ms avg latency
- **Auth (Register):** 112.4 req/s, 89ms avg latency
- **Messages:** 44.4 req/s, 225ms avg latency
- **Contacts/Groups:** ~9 req/s, 1.0-1.1s avg latency

## 👥 Team

**Group 60** - AGISIT 2025/2026, IST-Alameda
- Antero Cabral Marques Morgado (ist1119213)
- António Miguel Duarte Palma (ist1119203)

**Last edited in Jan-2025**

</details>

---

<p align="center">
  <i>Microservices Messaging Platform | MSc Computer Science and Engineering</i>
</p>
