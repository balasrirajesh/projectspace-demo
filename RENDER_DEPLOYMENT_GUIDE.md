# 🚀 Deploying GraduWay to Render.com

This guide provides step-by-step instructions to deploy **GraduWay** (WebRTC Signaling Backend + Flutter Web Application) on Render.com.

---

## 🏗️ Architecture on Render

```
                                  ┌────────────────────────┐
                                  │      Render CDN        │
                                  │   (graduway-web)       │
                                  │   Flutter Web App      │
                                  └───────────┬────────────┘
                                              │ HTTPS / WSS
                                              ▼
┌──────────────────────┐         ┌────────────────────────┐
│  MongoDB Atlas Cloud │ ◄────── │  Render Web Service    │
│  (Free M0 Cluster)   │ MONGODB │  (graduway-backend)    │
└──────────────────────┘  _URI   │  Node.js WebRTC Server │
                                 └────────────────────────┘
```

---

## ⚡ Option 1: 1-Click Blueprint Deployment (Recommended)

Render can automatically read the [`render.yaml`](render.yaml) file in the root repository.

1. Go to **[Render Dashboard](https://dashboard.render.com/)**.
2. Click **New +** $\rightarrow$ **Blueprint**.
3. Select your GitHub repository (`alumini_screen` / `GraduWay`).
4. Render will automatically detect `render.yaml` and configure:
   - **`graduway-backend`** (Node.js Web Service on Free Tier, 512 MB RAM)
   - **`graduway-web`** (Static Site with SPA routing rules)
5. Fill in the **`MONGODB_URI`** parameter when prompted (e.g. your MongoDB Atlas connection string).
6. Click **Apply**. Render will build and deploy both services!

---

## 🛠️ Option 2: Manual Step-by-Step Deployment

### Step 1: Deploy Backend (`graduway-backend`)

1. In Render Dashboard, click **New +** $\rightarrow$ **Web Service**.
2. Connect your Git repository.
3. Configure the settings:
   - **Name**: `graduway-backend`
   - **Root Directory**: `signaling_server`
   - **Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node index.js`
   - **Instance Type**: `Free`
4. Add **Environment Variables**:
   - `NODE_ENV` = `production`
   - `NODE_OPTIONS` = `--max-old-space-size=384`
   - `START_MEDIA_SERVER` = `false`
   - `MONGODB_URI` = `mongodb+srv://<username>:<password>@cluster0.xxx.mongodb.net/alumni_app?retryWrites=true&w=majority`
5. Under **Advanced** $\rightarrow$ **Health Check Path**: `/health`
6. Click **Create Web Service**. Your backend URL will be:
   ```
   https://graduway-backend.onrender.com
   ```

---

### Step 2: Deploy Frontend (`graduway-web`)

1. In your local terminal, build the Flutter Web production release bundle:
   ```bash
   flutter build web --release
   ```
2. In Render Dashboard, click **New +** $\rightarrow$ **Static Site**.
3. Configure settings:
   - **Name**: `graduway`
   - **Build Command**: `flutter build web --release` *(or leave blank if deploying pre-built `build/web`)*
   - **Publish Directory**: `build/web`
4. Under **Redirects/Rewrites**:
   - **Type**: `Rewrite`
   - **Source**: `/*`
   - **Destination**: `/index.html`
5. Click **Create Static Site**. Your website will be live at:
   ```
   https://graduway.onrender.com
   ```

---

## 📱 Mobile App Configuration (.env)

For mobile builds (Android APK / iOS), point your `.env` file to your live Render backend:

```env
SIGNALING_URL=https://graduway-backend.onrender.com
```

Then build the release APK:
```bash
flutter build apk --release
```

---

## 🔒 Free Tier Optimization Notes
- **RAM Footprint**: GraduWay's Node.js backend uses **~82 MB RAM** at idle and **~120 MB RAM** under active WebRTC signaling. It runs comfortably within Render's 512 MB free tier.
- **WebRTC Traffic**: Video and audio data are streamed Peer-to-Peer (device-to-device), ensuring zero bandwidth bottlenecks on the Render server.
- **Spin Down**: Free tier services sleep after 15 min of inactivity. Keep-alive pings to `https://graduway-backend.onrender.com/health` can keep it awake if desired.
