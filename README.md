# ShuttleIT 🚌⚡

> **Smart Campus Shuttle Tracking, Digital Ticketing & Fleet Management System for VIT Vellore**

ShuttleIT is a modern Flutter-based web and mobile platform designed to streamline campus transit. It provides real-time shuttle location tracking along precise campus road networks, multi-ticket digital booking with QR passes, conductor ticket scanning, dynamic seat occupancy tracking, and comprehensive admin fleet controls.

---

## 🌟 Key Features

### 🗺️ Live Campus Shuttle Tracking
- Real-time GPS simulation and live tracking along OpenStreetMap coordinates of the VIT Vellore campus.
- Dedicated routes:
  - **Route 1 (Cyan Path):** Main Gate ↔ SJT / Foodys via Technology Tower
  - **Route 2 (Orange Path):** Tech Tower ↔ PRPR via Main Gate & MB
  - **Route 3 (Green Path):** Foodys ↔ SMV via SJT & Anna Auditorium
- Route-specific glowing bus markers with dynamic bearings, next stop ETAs, and speed indicators.

### 🎟️ Multi-Seat Digital Ticketing & QR Passes
- Students can book 1 to 5 passes in a single transaction.
- Instant QR code generation with unique ticket hash and security checksum.
- Dynamic campus fare calculation (₹20 per seat).
- Instant cross-tab and cross-device revenue and occupancy updates.

### 📱 Conductor / Driver Console
- Quick QR ticket scanning with instant passenger boarding decrement/increment.
- Campus trip management (Start Trip / End Trip).
- Route status control (Route Open / Route Closed toggle).
- On-bus cash ticketing support.

### 📊 Admin Fleet Command Center
- Live revenue analytics calculated directly from valid ticket transactions.
- Live bus capacity and occupancy meters.
- Remote campus route control (Open/Close switches for any route).
- Active fleet diagnostics and driver assignment.

---

## 🔑 Default Credentials

For quick testing, ShuttleIT comes with pre-configured accounts:

| Role | Email | Password | Details |
| :--- | :--- | :--- | :--- |
| **Student** | `student@vit.ac.in` | `password123` | Book passes, live map, view QR tickets |
| **Driver 1** | `driver01@vit.ac.in` | `password123` | Conductor for Bus 01 (Route 1) |
| **Driver 2** | `driver02@vit.ac.in` | `password123` | Conductor for Bus 02 (Route 2) |
| **Driver 3** | `driver03@vit.ac.in` | `password123` | Conductor for Bus 03 (Route 3) |
| **Admin** | `admin@vit.ac.in` | `password123` | Fleet management, route control, revenue |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0.0+)
- Chrome browser (for Web) or Android Studio / Xcode (for Mobile)

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/hasishvallabhaneni11-eng/ShuttleIT.git
   cd ShuttleIT
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run on Chrome:
   ```bash
   flutter run -d chrome --web-port=8080
   ```

---

## 🛠️ Architecture & Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider Architecture (`BusProvider`, `TicketProvider`, `AuthProvider`)
- **Backend & Database:** Firebase Auth, Cloud Firestore, Realtime Database (with custom offline fallback and cross-tab storage synchronization)
- **Mapping:** Flutter Map with OpenStreetMap raster tiles and custom vector polyline rendering
- **Security:** Strict Firestore security rules with authenticated role validation
