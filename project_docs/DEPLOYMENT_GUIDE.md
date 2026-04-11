# 🚀 Deployment Guide: OpenShift (Signaling Server)

This guide provides instructions to deploy your Node.js signaling server to an OpenShift cluster using the provided Kubernetes manifests and Jenkins automation.

---

## 🏗️ Phase 1: Local Environment Setup

### 1. Install OpenShift CLI (`oc`)
- Download the `oc` client from the [OpenShift Console](https://console-openshift-console.apps.cluster.com) (Command Line Tools section).
- Add the `oc` executable to your system **PATH**.

### 2. Login to Cluster
Open your terminal and run the login command copied from the Web Console:
```bash
oc login https://api.cluster-url:6443 --token=YOUR_TOKEN
```

### 3. Create Project (Namespace)
```bash
oc new-project alumni-live
```

---

## 🛠️ Phase 2: Deployment via Jenkins

The included **Jenkinsfile** is pre-configured for OpenShift.

### 1. Configure Jenkins Credentials
- Go to your Jenkins Job > **Configure**.
- In the **Environment Settings**, ensure `OC_SERVER` and `OC_TOKEN` are set correctly.
- *Tip: Use the "Credentials" plugin in Jenkins to store the token securely.*

### 2. Deployment Flow
1. **Binary Build**: Jenkins sends the `signaling_server` folder to OpenShift's internal registry.
2. **Apply Manifests**: Jenkins applies `openshift/deployment.yaml` and `openshift/service.yaml`.
3. **Route**: The server is exposed via an OpenShift Route (HTTPS enabled by default).

---

## 🌐 Phase 3: Getting Your Public URL

After a successful deployment, retrieve your public endpoint:
```bash
oc get routes
```
Look for the **HOST/PORT** column. It will look like: 
`https://signaling-server-alumni-live.apps.cluster.com`

- Copy this URL.
- Open `lib/src/shared/providers/auth_provider.dart` and update `_productionSignalingUrl` with this value.

---

## 🔍 Troubleshooting

- **Check Pod Status**: `oc get pods`
- **View Logs**: `oc logs -f deployment/signaling-server`
- **Build Logs**: `oc logs -f bc/signaling-server`
- **Permissions Error**: Ensure your user has the `edit` or `admin` role in the project.
