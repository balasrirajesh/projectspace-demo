# 📱 Two-Device WebRTC Testing Checklist

Follow these steps to verify that your live class system is working correctly between two physical mobile devices.

---

## 🏗️ Pre-Testing
- [ ] Signaling server is deployed (Render/EC2) and status is "Live".
- [ ] `lib/src/shared/providers/auth_provider.dart` has the correct `_productionSignalingUrl`.
- [ ] You have generated the Release APK via Jenkins or manually (`flutter build apk --release`).
- [ ] The APK is installed on **Device A** and **Device B**.
- [ ] Both devices have a working internet connection (test across different networks like WiFi vs Data if possible).

---

## 🔴 Phase 1: Alumni (Host) Setup
1. **Open App** on Device A.
2. **Log In** as an Alumni (e.g., `alumni@test.com`).
3. Navigate to **Mentorship Hub** > **Live Sessions**.
4. Click the **(+) FAB** to "Create Live Class".
5. Enter a **Class Title** (e.g., "WebRTC Demo").
6. Click **Start Class**.
7. **Verify**:
   - [ ] Local camera preview is visible.
   - [ ] Status indicator shows "Live: Waiting for students...".
   - [ ] Room ID is displayed at the top.

---

## 🔵 Phase 2: Student (Attendee) Join
1. **Open App** on Device B.
2. **Log In** as a Student (e.g., `student@stud.com`).
3. Navigate to **Mentorship Hub** > **Live Sessions**.
4. Find the session titled "WebRTC Demo" (or join via ID if prompted).
5. Click **Join Now**.
6. **Verify**:
   - [ ] Local camera preview (Device B) is visible.
   - [ ] Student sees the Alumni's video stream within 2-5 seconds.
   - [ ] Alumni (Device A) sees the Student's video stream.

---

## 💬 Phase 3: Interaction Verification
1. **Chat**: Send a message from Device B. Verify it appears on Device A.
2. **Hand Raise**: Click the "Raise Hand" icon on Device B. Verify a notification appears on Device A.
3. **Audio**: Toggle mute on both devices and verify audio streams.
4. **Leave**: Exit the classroom on Device A. Verify Device B receives a "Mentor has left" notification and returns to the previous screen.

---

## 🛠️ Troubleshooting
- **Black Screen?**: Usually an ICE candidate failure. Ensure the STUN servers in `classroom_service.dart` are correct.
- **Unreachable?**: Check if your Render instance has "spun down" due to inactivity (it takes ~30s to wake up on the free tier).
- **Audio Echo?**: Use headphones on both devices to prevent feedback loops during testing.
