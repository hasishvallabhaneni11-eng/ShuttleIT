# 🚀 Linking VIT SmartShuttle with Firebase ("ShuttleIT")

Your Flutter app is already built with a **Dual-Mode Engine**:
* **Demo / Simulation Mode (Active Right Now)**: Works immediately out of the box with zero cloud setup. Perfect for testing, hackathon presentations, and offline development.
* **Live Firebase Cloud Mode**: When you want real cloud synchronization across multiple phones.

---

## 2-Step Firebase Connection

### Step 1: Login to Firebase CLI
Open PowerShell in the `vit_shuttle` folder and run:
```powershell
firebase login
```
A browser window will open. Select your Google account (`hasishvallabhaneni11@gmail.com`) and allow access.

---

### Step 2: Configure FlutterFire
In the same terminal, run:
```powershell
flutterfire configure
```
1. Select your Firebase project: **`ShuttleIT`** (or `project-64460747519`)
2. Select platforms: **android**, **web** (use Spacebar to select, Enter to confirm)
3. FlutterFire will automatically generate `lib/firebase_options.dart` and register your Android package (`com.vit.shuttle.vit_shuttle`).

---

## Step 3: Run the App!

### To test on Web (Admin / Student / Driver):
```powershell
flutter run -d chrome
```

### To test on Android Phone / Emulator:
Connect your phone with USB debugging enabled, or start an emulator from Android Studio:
```powershell
flutter run
```

### To build the Android APK:
```powershell
flutter build apk --release
```
The output APK will be saved at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Default Demo Accounts (Pre-seeded for 1-Tap Login)

| Role | Email | Password | Features |
|---|---|---|---|
| **Student** | `student@vit.ac.in` | `password123` | Live OpenStreetMap, ETA, ₹20 digital pass booking, QR pass display |
| **Driver 01** | `driver01@vit.ac.in` | `password123` | Assigned to **VIT Shuttle 01**, GPS tracking toggle, QR ticket scanner, ₹20 cash pass |
| **Driver 02** | `driver02@vit.ac.in` | `password123` | Assigned to **VIT Shuttle 02**, SJT Express route |
| **Admin** | `admin@vit.ac.in` | `password123` | Fleet control center, live revenue audit, simulation mode toggle |
