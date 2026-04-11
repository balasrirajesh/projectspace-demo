# 🚀 WebRTC Setup Guide - All Devices

## Complete Setup for PC, Laptop, Mobile (Phone & Tablet)

---

## 📋 Prerequisites

- **Server Machine**: Running Node.js signaling server on port 3000
- **All Devices**: Connected to same WiFi network (or VPN for remote)
- **Ports**: Ensure port 3000 is not blocked by firewall

---

## ✅ Step 1: Start the Signaling Server

On your **server machine** (laptop/PC where you have the code):

```bash
cd "C:\project space\alumini_screen\signaling_server"
npm install   # If not done already
npm start
```

**Expected output:**
```
WebRTC signaling server listening on port 3000
```

**Verify:** Open browser and go to `http://localhost:3000` - you should see a response.

---

## ✅ Step 2: Find Your Server's Network IP

On the **server machine**:

### Windows:
```powershell
ipconfig
```

Look for **IPv4 Address** under your WiFi adapter. Example: `192.168.1.100` or `10.97.84.39`

### Mac/Linux:
```bash
ifconfig
```

Look for `inet` address under your WiFi adapter.

**Save this IP** - you'll use it on all other devices.

---

## ✅ Step 3: Connect All Devices

### On Each Device (Phone, Tablet, Laptop, PC):

1. **Ensure on Same WiFi**: All devices must be on the same WiFi network as server
   
2. **Open the App** → Go to **Settings** → **Server Settings**

3. **Auto-Detect Option** (Recommended):
   - Tap **"Scan Network for Server"**
   - Wait for scan to complete
   - If server IP appears → Tap it
   - Tap **"Test Connection"** → Should show ✅
   - Tap **"Save IP Address"**

4. **Manual Configuration** (If scan doesn't find server):
   - Manually enter server IP in the text field
   - Example: `192.168.1.100`
   - Tap **"Test Connection"**
   - When ✅ appears → Tap **"Save IP Address"**
   - Restart app

---

## ✅ Step 4: Test WebRTC Connection

1. **Open App on 2+ Devices**
2. **Login as**:
   - Device 1: Mentor/Alumni
   - Device 2: Student
3. **One Mentor/Alumni creates classroom**
4. **Students join the classroom**
5. **Test**:
   - ✅ Video streams
   - ✅ Audio works
   - ✅ Chat messages
   - ✅ Hand raise notifications

---

## 📱 Device-Specific Setup

### Android Phone/Tablet
- Open Settings → Server Settings
- If on same WiFi:
  - Tap "Scan Network" → auto-find server
  - No manual IP needed
- Port: Automatically 3000

### iOS iPhone/iPad
- Same as Android
- WiFi is preferred (mobile data won't see local servers)
- Ensure same network as server machine

### Windows Laptop/PC
- Same as above
- Can use IP directly without scanning

### Mac
- Same as others
- Ensure firewall allows port 3000

---

## 🔧 Troubleshooting

### "Server Unreachable" Error

**Problem**: App can't find server

**Solutions**:
1. **Check Server is Running**:
   ```bash
   netstat -ano | findstr ":3000"
   ```
   Should show `LISTENING` status

2. **Check Firewall**:
   - Allow port 3000 through Windows/Mac firewall
   - Or disable firewall temporarily for testing

3. **Check WiFi**:
   - All devices on same WiFi?
   - Try: `Scan Network for Server`
   - If no results → server isn't running

4. **Wrong IP**:
   - Verify server IP with `ipconfig`
   - Try entering it manually
   - Test with laptop first before mobile

### Connected but Video/Audio Not Working

**Solutions**:
1. Grant app permissions:
   - Camera: ✅ Allow
   - Microphone: ✅ Allow
   - Network: ✅ Allow

2. Check network:
   - Ping server: `ping 192.168.1.100` (replace with your IP)
   - Ensure no firewall blocking WebRTC

3. Restart app and try again

### Scan Finds Multiple Servers

**Expected if**: Multiple machines have server running

**Solution**: 
- Test each one
- Use the one that works (✅ green check)

---

## 📊 Network Topology

```
┌─────────────────────────────────┐
│     Server Machine              │
│  npm server port 3000           │
│  IP: 192.168.1.100              │
└────────────────┬────────────────┘
                 │
        ┌────────┼────────┐
        │                 │
    ┌───────┐        ┌───────┐
    │ Phone │        │ PC    │
    │ WiFi  │        │ WiFi  │
    └───────┘        └───────┘
        │                 │
        └────────────────┬─┘
        All connect to same IP:3000
```

---

## ✨ Features Enabled

Once setup complete, all devices can:

- **Join classrooms** (Student or Mentor role)
- **Video conferencing** (WebRTC peer-to-peer)
- **Chat messaging** (Real-time)
- **Hand raise** (Notifications for mentor)
- **Screen share** (If enabled)
- **Multiple concurrent connections**

---

## 🎯 Quick Checklist

- [ ] Server running on machine (`npm start`)
- [ ] Found server IP (`ipconfig`)
- [ ] All devices on same WiFi
- [ ] Each device: Settings → Server Settings → Save IP
- [ ] Test: Open Classroom
- [ ] ✅ Video/Audio working

---

## 📞 Still Having Issues?

1. Check server logs for errors
2. Verify firewall settings
3. Try restarting both server and app
4. Test with laptop first (simpler than phone)
5. Ensure port 3000 isn't used by something else:
   ```bash
   netstat -ano | findstr ":3000"
   ```

---

**Setup Complete! 🎉 Ready for WebRTC conferencing!**
