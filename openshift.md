# 🏗️ OpenShift Deployment Procedure

This document provides the exact code, commands, and steps required to move your signaling server from your local machine to an enterprise OpenShift cluster.

---

## 1️⃣ Prerequisites (One-Time Setup)

Before you start the deployment, ensure your local Jenkins machine has:
1.  **OpenShift CLI (`oc`)**: [Download and add to PATH](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/).
2.  **Jenkins Credentials**: You will need a **Server URL** and a **Login Token**.

---

## 2️⃣ Step-by-Step Deployment Procedure

### Step A: Login & Project Creation
Run these commands in your Windows terminal (PowerShell/CMD):
```powershell
# 1. Login to your cluster (Get this command from the OpenShift Web Console)
oc login https://api.cluster-url:6443 --token=YOUR_TOKEN

# 2. Create the project for your app
oc new-project alumni-live
```

### Step B: Prepare the Binary Build
We use a "Binary Build" to send your local `signaling_server` folder directly to OpenShift's internal registry.
```powershell
# Create the build configuration (Only run this once)
oc new-build --name signaling-server --binary=true
```

### Step C: Trigger the Deployment via Jenkins
The updated `Jenkinsfile` now handles this automatically. Every time you click **"Build Now"** in Jenkins:
1.  It runs `flutter clean` and builds your APK.
2.  It sends your `signaling_server/` code to OpenShift using:
    `oc start-build signaling-server --from-dir=signaling_server`
3.  It applies the manifests in the `openshift/` folder:
    `oc apply -f openshift/deployment.yaml`
    `oc apply -f openshift/service.yaml`

---

## 3️⃣ Public Access (Routes)

After the build completes, your app is running inside the cluster. To make it public:
```powershell
# Expose the service as a Route (Jenkins does this via service.yaml)
oc get routes
```
**Look for the URL in the output:**
> Host: `signaling-server-alumni-live.apps.cluster.com`

---

## 4️⃣ Update Flutter App
Now that your server is live, you must tell your Flutter app where to find it.

1.  Open `lib/src/shared/providers/auth_provider.dart`.
2.  Update the following line with your OpenShift Route URL:
```dart
static const String _productionSignalingUrl = 'https://signaling-server-alumni-live.apps.cluster.com';
```

---

## 5️⃣ Deployment Cheat Sheet

| Action | Command |
| :--- | :--- |
| **Check Logs** | `oc logs -f deployment/signaling-server` |
| **Check Pods** | `oc get pods` |
| **Restart App** | `oc rollout restart deployment/signaling-server` |
| **Get Public URL** | `oc get route signaling-server` |
| **Check Build Status** | `oc describe build signaling-server` |

---

### 🚀 Final Goal
Once you finish these steps, your **Jenkins pipeline** will be the brain of your project:
- **Local changes** in Flutter ➡️ **Jenkins** ➡️ **New APK** generated.
- **Local changes** in Signaling ➡️ **Jenkins** ➡️ **OpenShift** updated automatically.
