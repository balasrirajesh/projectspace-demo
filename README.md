# Alumni Screen - Unified Architecture

Welcome to the **Alumni Screen** project. This project has been modernized into a streamlined, high-performance architecture using a **Unified Node.js Backend** and a **Flutter Frontend**.

## 🏗️ Architecture Overview

The project is split into two primary components:

1.  **Flutter Frontend (`/lib`)**: A cross-platform mobile and web application.
2.  **Unified Node.js Backend (`/signaling_server`)**: A single-service backend that handles:
    - RESTful APIs (Chat, User Management, Mentorship).
    - WebRTC Signaling logic.
    - Node-Media-Server for live broadcasting.
    - MongoDB persistence.

---

## 📂 Project Structure

| Directory | Purpose |
| :--- | :--- |
| `lib/` | Flutter application source code. |
| `signaling_server/` | **Unified Backend** (Express, Socket.io, Mongoose). |
| `openshift/` | Kubernetes/OpenShift deployment manifests. |
| `scripts/` | Project utility and helper scripts. |
| `project_docs/` | Detailed documentation and setup guides. |
| `android/ios/...` | Platform-specific Flutter configuration. |

---

## 🚀 Quick Start (Local Development)

### 1. Prerequisites
- **Flutter SDK** (v3.19+)
- **Node.js** (v20+)
- **MongoDB** (Running locally or via Docker)
- **FFmpeg** (Required for media broadcasting)

### 2. Run the Backend
You can run the backend directly or via Docker Compose.

**Manual Start:**
```powershell
cd signaling_server
npm install
npm start
```
*Alternatively, use the helper script:* `.\scripts\run_dev_backend.bat`

**Docker Compose:**
```powershell
docker-compose up --build
```

### 3. Run the Frontend
```powershell
flutter pub get
flutter run
```

---

## 🛠️ CI/CD & Deployment

This project uses an automated **Jenkins Pipeline** for testing and deployment.

- **Pipeline**: Defined in `Jenkinsfile`.
- **Target**: Deployed to **OpenShift** as a containerized service.
- **Monitoring**: SonarQube analysis is automatically performed on every merge to `main`.

Refer to [openshift.md](openshift.md) for detailed deployment environment information.

---

## 📄 Documentation Links
- [Deployment Guide](project_docs/DEPLOYMENT_GUIDE.md)
- [WebRTC Setup Guide](project_docs/WEBRTC_SETUP_GUIDE.md)
- [Testing Checklist](project_docs/TESTING_CHECKLIST.md)
