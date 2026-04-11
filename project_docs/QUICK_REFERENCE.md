# 📱 WebRTC Classroom - Quick Reference Card

## ⚡ 30-Second Setup

1️⃣ **Server Running?**  
```
npm start  (in signaling_server folder)
```

2️⃣ **Same WiFi?**  
✅ All devices on same WiFi network

3️⃣ **Open App → ⚙️ Settings → Scan Network**  
✅ Select server IP → Test → Save

4️⃣ **Done!** Create or join classroom

---

## 📍 Server IP Location

Your server is running at:  
**http://[YOUR_IP]:3000**

### Find Your IP:
```powershell
ipconfig
```
Look for: **IPv4 Address** (e.g., 192.168.1.100)

---

## 📱 Per Device Setup

### 🔄 Automatic (Recommended)
- App → Dashboard ⚙️ (top right)
- Tap "Scan Network for Server"
- Select IP → Test → Save
- **✅ Ready to join classrooms!**

### ⚙️ Manual Setup
- App → Dashboard ⚙️
- Enter: `YOUR_SERVER_IP:3000`
- Test → Save
- Restart app

---

## ✅ Test Checklist

- [ ] Server running (`npm start`)
- [ ] All on same WiFi
- [ ] Each device → Settings → Save IP
- [ ] ✅ Green check shows in test
- [ ] Can create classroom (Alumni)
- [ ] Can join classroom (Student)
- [ ] Video + Audio working

---

## 🆘 Quick Troubleshot

| Issue | Fix |
|-------|-----|
| Server unreachable | Check `npm start`, firewall, same WiFi |
| No video/audio | Check permissions: App Settings → Allow Camera/Mic |
| Scan finds nothing | Server not running, or firewall blocking |
| Can't find IP | Run `ipconfig` on server machine |

---

## 🎯 Supported Devices

✅ Windows PC  
✅ Mac Laptop  
✅ Android Phone/Tablet  
✅ iPhone/iPad  

---

## 📞 Server Details

| Component | Status |
|-----------|--------|
| **Port** | 3000 |
| **Protocol** | Socket.io (Signaling) + WebRTC (Data) |
| **Status** | ✅ Running |

---

## 💡 Pro Tips

1. **Test with laptop first** → easier to debug
2. **All devices need same WiFi** → no mobile data!
3. **Keep server running** → while anyone in classroom
4. **Clear app cache** if issues → Settings → Clear Cache
5. **Restart app** after saving IP

---

**Start WebRTC Session Now:** Open App → Dashboard → Select Classroom 🎬
