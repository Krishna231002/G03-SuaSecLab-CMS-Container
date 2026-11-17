# G03 — SUASecLab CMS Container

Containerising a deliberately vulnerable machine from the **SUASecLab** as a lightweight
container — a proof of concept to reduce resource use and improve scalability while keeping
isolation comparable to a virtual machine.

> **Course project** — Schmalkalden University of Applied Sciences · Group **G03**

## Security notice
This repository builds an **intentionally vulnerable** system for **security education and
research only**. **Do not** expose it to the public internet, run it in production, or deploy
it on any untrusted network. No access credentials, lab links, or secrets belong in this repo.

## What this project does
The SUASecLab runs each student's vulnerable machines as full **virtual machines (VMs)**, which
is heavy on memory and CPU and limits how many students the lab can support. This project rebuilds
one vulnerable machine — **`suasploitable-cms`** (a WordPress/Drupal server) — as a **Docker
container**, then measures it against the VM to see whether containers can give the same learning
environment with far fewer resources.

### Research questions
**Main question:** *Can a vulnerable machine be containerised to reduce memory consumption and
improve the scalability of the SUASecLab while maintaining a level of isolation and security
comparable to the existing virtual machine?*

Four sub-questions:
- **RQ1 – Memory:** how much memory does each containerised instance use vs a VM?
- **RQ2 – Scalability:** how many instances run on one host vs VMs?
- **RQ3 – Isolation:** can a compromised container stay isolated from the host and other instances?
- **RQ4 – Functionality:** does the container keep the same services, vulnerabilities and CTF flags?

## Tech stack
| Area | Tool |
|---|---|
| Containerisation | **Docker** |
| Image scanning | **Trivy** |
| Orchestration / scale | **k3s** (lightweight Kubernetes) |
| Stronger isolation | **gVisor / Kata Containers** |
| Baseline VM | **QEMU/KVM + Packer** |
| Automation (CI) | **GitHub Actions** |


## Planned repository structure
```
.
├── container/     # Dockerfile(s) for the CMS container
├── baseline-vm/   # notes / scripts for the existing lab VM baseline
├── k8s/           # k3s / Kubernetes manifests
├── hardening/     # seccomp profiles, dropped capabilities, network policies
├── scripts/       # deploy script, measurement scripts
├── results/       # measurement data (CSV) and charts
└── .github/workflows/   # CI pipeline (build + Trivy scan)
```
*(Folders are added as the work progresses.)*

## Team G03
| Member | Role |
|---|---|
| Krishna Kapadia | Project Lead — coordination, documentation assembly, presentation |
| Adiljith Babu | Editor — all written documents |
| Vaibhav Patel | Developer — container image + Trivy scanning |
| Nilkanth Thakkar | Developer — k3s scaling, memory measurement, hardening, gVisor/Kata |
| Kanishk Pachory | Developer — automation (GitHub Actions), deploy script, network integration |

## Working with this repo (for team members)
Clone it once:
```bash
git clone https://github.com/Krishna231002/G03-SuaSecLab-CMS-Container.git
```
Daily workflow:
```bash
git pull          # get the latest team changes (start of session)
# ... do your work ...
git add .
git commit -m "describe what you did"
git push          # share your changes (end of session)
```

---

## Status
- **Now → January:** working prototype on a laptop (container + measurements).
- **January:** proof-of-concept presentation.
- **January → March:** integration into the SUASecLab server + final measurements and report.

---