// Seed script for ShuttleIT Firebase Firestore
// Uses the Firebase Web SDK with the project's config (no service account needed)
// Run: node seed_firestore.js

const { initializeApp } = require('firebase/app');
const { getFirestore, doc, setDoc } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: 'AIzaSyDlgSxlPra4rpvLD_tq6MV3u6vLhZXiBfA',
  authDomain: 'shuttleit-c21af.firebaseapp.com',
  projectId: 'shuttleit-c21af',
  storageBucket: 'shuttleit-c21af.firebasestorage.app',
  messagingSenderId: '64460747519',
  appId: '1:64460747519:web:0c58cba393d744b01d52ca',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function seedUsers() {
  const users = [
    {
      uid: 'user_student_1',
      name: 'Rahul Sharma',
      email: 'student@vit.ac.in',
      role: 'student',
      regNumber: '22BCE1042',
      phone: '+91 9876543210',
    },
    {
      uid: 'user_driver_1',
      name: 'Murugan K.',
      email: 'driver01@vit.ac.in',
      role: 'driver',
      driverId: 'DRV-101',
      assignedBusId: 'BUS-01',
      phone: '+91 9876543211',
    },
    {
      uid: 'user_driver_2',
      name: 'Ramesh Sundaram',
      email: 'driver02@vit.ac.in',
      role: 'driver',
      driverId: 'DRV-102',
      assignedBusId: 'BUS-02',
      phone: '+91 9876543212',
    },
    {
      uid: 'user_driver_3',
      name: 'Anand Kumar',
      email: 'driver03@vit.ac.in',
      role: 'driver',
      driverId: 'DRV-103',
      assignedBusId: 'BUS-03',
      phone: '+91 9876543213',
    },
    {
      uid: 'user_admin_1',
      name: 'Campus Transport Admin',
      email: 'admin@vit.ac.in',
      role: 'admin',
      phone: '+91 9876543200',
    },
  ];

  for (const user of users) {
    await setDoc(doc(db, 'users', user.uid), user);
    console.log(`  ✓ User ${user.name} (${user.role}) seeded`);
  }
}

async function seedBuses() {
  const buses = [
    {
      busId: 'BUS-01',
      busNumber: 'VIT Shuttle 01',
      routeId: 'ROUTE-01',
      routeName: 'Hostels ➔ TT ➔ Main Gate',
      driverId: 'user_driver_1',
      driverName: 'Murugan K.',
      active: true,
      capacity: 35,
      currentOccupancy: 12,
    },
    {
      busId: 'BUS-02',
      busNumber: 'VIT Shuttle 02',
      routeId: 'ROUTE-02',
      routeName: 'Main Gate ➔ SJT Express',
      driverId: 'user_driver_2',
      driverName: 'Ramesh Sundaram',
      active: true,
      capacity: 35,
      currentOccupancy: 8,
    },
    {
      busId: 'BUS-03',
      busNumber: 'VIT Shuttle 03',
      routeId: 'ROUTE-03',
      routeName: 'Ladies Hostel ➔ Academic Zone',
      driverId: 'user_driver_3',
      driverName: 'Anand Kumar',
      active: true,
      capacity: 35,
      currentOccupancy: 6,
    },
  ];

  for (const bus of buses) {
    await setDoc(doc(db, 'buses', bus.busId), bus);
    console.log(`  ✓ Bus ${bus.busNumber} (${bus.busId}) seeded`);
  }
}

async function seedRoutes() {
  const routes = [
    {
      routeId: 'ROUTE-01',
      code: 'R1',
      name: 'Hostels ➔ TT ➔ Main Gate',
      description: "Men's Hostels via Chandra Ave, Fleming Roundabout, Technology Tower to Main Gate",
      colorHex: 'ff00d2ff',
      isActive: true,
      stops: [
        { stopId: 'S1-1', name: "Men's Hostel (Block D/E)", latitude: 12.9680, longitude: 79.1545, order: 1, isMajorHub: true },
        { stopId: 'S1-2', name: 'Chandra Avenue Junction', latitude: 12.9688, longitude: 79.1553, order: 2, isMajorHub: false },
        { stopId: 'S1-3', name: 'Fleming Roundabout', latitude: 12.9696, longitude: 79.1559, order: 3, isMajorHub: false },
        { stopId: 'S1-4', name: 'Technology Tower (TT)', latitude: 12.9712, longitude: 79.1565, order: 4, isMajorHub: true },
        { stopId: 'S1-5', name: 'Amartya Sen Avenue / Main Gate', latitude: 12.9709, longitude: 79.1581, order: 5, isMajorHub: true },
      ],
      polyline: [
        { lat: 12.9680, lng: 79.1545 },
        { lat: 12.9681, lng: 79.1547 },
        { lat: 12.9682, lng: 79.1550 },
        { lat: 12.9684, lng: 79.1552 },
        { lat: 12.9686, lng: 79.1553 },
        { lat: 12.9688, lng: 79.1553 },
        { lat: 12.9690, lng: 79.1553 },
        { lat: 12.9693, lng: 79.1553 },
        { lat: 12.9696, lng: 79.1553 },
        { lat: 12.9696, lng: 79.1556 },
        { lat: 12.9696, lng: 79.1559 },
        { lat: 12.9696, lng: 79.1562 },
        { lat: 12.9696, lng: 79.1566 },
        { lat: 12.9696, lng: 79.1572 },
        { lat: 12.9688, lng: 79.1572 },
        { lat: 12.9687, lng: 79.1575 },
        { lat: 12.9687, lng: 79.1580 },
        { lat: 12.9687, lng: 79.1585 },
        { lat: 12.9700, lng: 79.1569 },
        { lat: 12.9708, lng: 79.1569 },
        { lat: 12.9709, lng: 79.1573 },
        { lat: 12.9709, lng: 79.1578 },
        { lat: 12.9709, lng: 79.1581 },
      ],
    },
    {
      routeId: 'ROUTE-02',
      code: 'R2',
      name: 'Main Gate ➔ SJT Express',
      description: 'Main Gate via Kissinger Road to Silver Jubilee Tower and back via Jimmy Carter Road',
      colorHex: 'ffff9100',
      isActive: true,
      stops: [
        { stopId: 'S2-1', name: 'Main Gate / Amartya Sen Ave', latitude: 12.9709, longitude: 79.1581, order: 1, isMajorHub: true },
        { stopId: 'S2-2', name: 'Planck Avenue (North)', latitude: 12.9733, longitude: 79.1567, order: 2, isMajorHub: false },
        { stopId: 'S2-3', name: 'Kissinger Road / SJT Junction', latitude: 12.9737, longitude: 79.1610, order: 3, isMajorHub: true },
        { stopId: 'S2-4', name: 'Silver Jubilee Tower (SJT)', latitude: 12.9714, longitude: 79.1616, order: 4, isMajorHub: true },
        { stopId: 'S2-5', name: 'Jimmy Carter Road (return)', latitude: 12.9720, longitude: 79.1647, order: 5, isMajorHub: false },
      ],
      polyline: [
        { lat: 12.9709, lng: 79.1581 },
        { lat: 12.9709, lng: 79.1575 },
        { lat: 12.9708, lng: 79.1569 },
        { lat: 12.9715, lng: 79.1565 },
        { lat: 12.9720, lng: 79.1566 },
        { lat: 12.9727, lng: 79.1566 },
        { lat: 12.9733, lng: 79.1567 },
        { lat: 12.9737, lng: 79.1567 },
        { lat: 12.9737, lng: 79.1580 },
        { lat: 12.9737, lng: 79.1590 },
        { lat: 12.9737, lng: 79.1598 },
        { lat: 12.9737, lng: 79.1606 },
        { lat: 12.9737, lng: 79.1610 },
        { lat: 12.9728, lng: 79.1610 },
        { lat: 12.9725, lng: 79.1610 },
        { lat: 12.9714, lng: 79.1616 },
        { lat: 12.9716, lng: 79.1626 },
        { lat: 12.9718, lng: 79.1636 },
        { lat: 12.9720, lng: 79.1647 },
      ],
    },
    {
      routeId: 'ROUTE-03',
      code: 'R3',
      name: 'Ladies Hostel ➔ Academic Zone',
      description: 'Ladies Hostel via Planck Avenue and Kissinger Road to TT and Academic Zone',
      colorHex: 'ff00e676',
      isActive: true,
      stops: [
        { stopId: 'S3-1', name: 'Ladies Hostel (LH)', latitude: 12.9744, longitude: 79.1568, order: 1, isMajorHub: true },
        { stopId: 'S3-2', name: 'Kissinger Road West', latitude: 12.9737, longitude: 79.1567, order: 2, isMajorHub: false },
        { stopId: 'S3-3', name: 'Technology Tower (TT)', latitude: 12.9712, longitude: 79.1565, order: 3, isMajorHub: true },
        { stopId: 'S3-4', name: 'Fleming Roundabout', latitude: 12.9696, longitude: 79.1559, order: 4, isMajorHub: false },
        { stopId: 'S3-5', name: 'Anna Auditorium', latitude: 12.9688, longitude: 79.1572, order: 5, isMajorHub: true },
      ],
      polyline: [
        { lat: 12.9744, lng: 79.1568 },
        { lat: 12.9737, lng: 79.1567 },
        { lat: 12.9733, lng: 79.1567 },
        { lat: 12.9727, lng: 79.1566 },
        { lat: 12.9720, lng: 79.1566 },
        { lat: 12.9715, lng: 79.1565 },
        { lat: 12.9712, lng: 79.1565 },
        { lat: 12.9709, lng: 79.1563 },
        { lat: 12.9708, lng: 79.1557 },
        { lat: 12.9707, lng: 79.1554 },
        { lat: 12.9704, lng: 79.1554 },
        { lat: 12.9703, lng: 79.1553 },
        { lat: 12.9696, lng: 79.1553 },
        { lat: 12.9696, lng: 79.1559 },
        { lat: 12.9696, lng: 79.1566 },
        { lat: 12.9696, lng: 79.1572 },
        { lat: 12.9688, lng: 79.1572 },
      ],
    },
  ];

  for (const route of routes) {
    await setDoc(doc(db, 'routes', route.routeId), route);
    console.log(`  ✓ Route ${route.code}: ${route.name} seeded`);
  }
}

async function seedTickets() {
  const now = new Date();
  const tickets = [
    {
      ticketId: 'VS-98231',
      userId: 'user_student_1',
      userName: 'Rahul Sharma',
      busId: 'BUS-01',
      busNumber: 'VIT Shuttle 01',
      routeId: 'ROUTE-01',
      routeName: 'Hostels ➔ TT ➔ Main Gate',
      fromStop: "Men's Hostel (Block D/E)",
      toStop: 'Technology Tower (TT)',
      amount: 20,
      status: 'paid',
      paymentMethod: 'upi',
      qrData: 'VIT_SHUTTLE_VS-98231_Q1',
      createdAt: new Date(now.getTime() - 15 * 60 * 1000).toISOString(),
      validUntil: new Date(now.getTime() + 3 * 60 * 60 * 1000).toISOString(),
      usedAt: null,
      scannedByDriverId: null,
    },
  ];

  for (const ticket of tickets) {
    await setDoc(doc(db, 'tickets', ticket.ticketId), ticket);
    console.log(`  ✓ Ticket ${ticket.ticketId} seeded`);
  }
}

async function main() {
  console.log('\n🚌 ShuttleIT — Seeding Firestore with 3 Routes, 3 Buses, & Fixed Credentials...\n');

  console.log('👥 Seeding users (3 drivers, 1 admin, 1 student)...');
  await seedUsers();

  console.log('\n📍 Seeding buses (BUS-01, BUS-02, BUS-03)...');
  await seedBuses();

  console.log('\n🗺️  Seeding routes (ROUTE-01, ROUTE-02, ROUTE-03)...');
  await seedRoutes();

  console.log('\n🎫 Seeding initial tickets...');
  await seedTickets();

  console.log('\n✅ Firestore seeded successfully!\n');
  process.exit(0);
}

main().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
