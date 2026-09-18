import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/user_model.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/ticket_model.dart';

/// All coordinates verified against OpenStreetMap data for VIT Vellore campus.
/// Named campus roads used: King Road, Planck Avenue, Kissinger Road,
/// Khorana Avenue, Fleming Road, Chandra Avenue, Jimmy Carter Road, Amartya Sen Avenue.
class SeedData {
  // 1. Initial Users (3 Drivers + 1 Admin + 1 Student)
  static List<AppUser> get initialUsers => [
    AppUser(
      uid: 'user_student_1',
      name: 'Rahul Sharma',
      email: 'student@vit.ac.in',
      role: UserRole.student,
      regNumber: '22BCE1042',
      phone: '+91 9876543210',
    ),
    AppUser(
      uid: 'user_driver_1',
      name: 'Murugan K.',
      email: 'driver01@vit.ac.in',
      role: UserRole.driver,
      driverId: 'DRV-101',
      assignedBusId: 'BUS-01',
      phone: '+91 9876543211',
    ),
    AppUser(
      uid: 'user_driver_2',
      name: 'Ramesh Sundaram',
      email: 'driver02@vit.ac.in',
      role: UserRole.driver,
      driverId: 'DRV-102',
      assignedBusId: 'BUS-02',
      phone: '+91 9876543212',
    ),
    AppUser(
      uid: 'user_driver_3',
      name: 'Anand Kumar',
      email: 'driver03@vit.ac.in',
      role: UserRole.driver,
      driverId: 'DRV-103',
      assignedBusId: 'BUS-03',
      phone: '+91 9876543213',
    ),
    AppUser(
      uid: 'user_admin_1',
      name: 'Campus Transport Admin',
      email: 'admin@vit.ac.in',
      role: UserRole.admin,
      phone: '+91 9876543200',
    ),
  ];

  // 2. Routes with REAL campus road coordinates from OSM
  static List<ShuttleRoute> get initialRoutes => [
    // ROUTE-01: Men's Hostel → Chandra Ave → Fleming Roundabout → Planck Ave → Kissinger Road → Main Gate area
    ShuttleRoute(
      routeId: 'ROUTE-01',
      code: 'R1',
      name: 'Hostels ➔ TT ➔ Main Gate',
      description: 'Men\'s Hostels via Chandra Ave, Fleming Roundabout, Technology Tower to Main Gate',
      color: const Color(0xFF00D2FF),
      stops: [
        RouteStop(
          stopId: 'S1-1', name: 'Men\'s Hostel (Block D/E)',
          location: const LatLng(12.9680, 79.1545), order: 1, isMajorHub: true,
        ),
        RouteStop(
          stopId: 'S1-2', name: 'Chandra Avenue Junction',
          location: const LatLng(12.9688, 79.1553), order: 2,
        ),
        RouteStop(
          stopId: 'S1-3', name: 'Fleming Roundabout',
          location: const LatLng(12.9696, 79.1559), order: 3,
        ),
        RouteStop(
          stopId: 'S1-4', name: 'Technology Tower (TT)',
          location: const LatLng(12.9712, 79.1565), order: 4, isMajorHub: true,
        ),
        RouteStop(
          stopId: 'S1-5', name: 'Amartya Sen Avenue / Main Gate',
          location: const LatLng(12.9709, 79.1581), order: 5, isMajorHub: true,
        ),
      ],
      // Follows: Hostel road → Chandra Avenue (King Road junction) → Fleming Road roundabout
      // → Khorana Avenue → Planck Avenue → TT area → Amartya Sen Avenue
      polyline: [
        const LatLng(12.9680, 79.1545),   // Men's Hostel start
        const LatLng(12.9681, 79.1547),   // Along hostel road
        const LatLng(12.9682, 79.1550),
        const LatLng(12.9684, 79.1552),
        const LatLng(12.9686, 79.1553),   // Chandra Avenue
        const LatLng(12.9688, 79.1553),   // Chandra Ave / King Rd junction (OSM node)
        const LatLng(12.9690, 79.1553),
        const LatLng(12.9693, 79.1553),   // Along Chandra Avenue heading east
        const LatLng(12.9696, 79.1553),
        const LatLng(12.9696, 79.1556),   // Turn south onto Fleming Road
        const LatLng(12.9696, 79.1559),   // Fleming Road Roundabout (OSM node)
        const LatLng(12.9696, 79.1562),   // Continue east on Fleming Road
        const LatLng(12.9696, 79.1566),   // Khorana Avenue junction
        const LatLng(12.9696, 79.1572),   // Along Khorana Avenue
        const LatLng(12.9688, 79.1572),   // King Road (south end)
        const LatLng(12.9687, 79.1575),
        const LatLng(12.9687, 79.1580),
        const LatLng(12.9687, 79.1585),   // King Road east terminus
        const LatLng(12.9700, 79.1569),   // Cut north toward Planck Ave
        const LatLng(12.9708, 79.1569),   // Souvenier Subway area
        const LatLng(12.9709, 79.1573),
        const LatLng(12.9709, 79.1578),   // Amartya Sen Avenue (OSM)
        const LatLng(12.9709, 79.1581),   // Main Gate area / terminus
      ],
    ),

    // ROUTE-02: Main Gate → Amartya Sen Ave → Kissinger Road → SJT → Jimmy Carter Road loop
    ShuttleRoute(
      routeId: 'ROUTE-02',
      code: 'R2',
      name: 'Main Gate ➔ SJT Express',
      description: 'Main Gate via Kissinger Road to Silver Jubilee Tower and back via Jimmy Carter Road',
      color: const Color(0xFFFF9100),
      stops: [
        RouteStop(
          stopId: 'S2-1', name: 'Main Gate / Amartya Sen Ave',
          location: const LatLng(12.9709, 79.1581), order: 1, isMajorHub: true,
        ),
        RouteStop(
          stopId: 'S2-2', name: 'Planck Avenue (North)',
          location: const LatLng(12.9733, 79.1567), order: 2,
        ),
        RouteStop(
          stopId: 'S2-3', name: 'Kissinger Road / SJT Junction',
          location: const LatLng(12.9737, 79.1610), order: 3, isMajorHub: true,
        ),
        RouteStop(
          stopId: 'S2-4', name: 'Silver Jubilee Tower (SJT)',
          location: const LatLng(12.9714, 79.1616), order: 4, isMajorHub: true,
        ),
        RouteStop(
          stopId: 'S2-5', name: 'Jimmy Carter Road (return)',
          location: const LatLng(12.9720, 79.1647), order: 5,
        ),
      ],
      // Follows: Amartya Sen Ave → north along Planck Avenue → east on Kissinger Road → SJT → return Jimmy Carter Road
      polyline: [
        const LatLng(12.9709, 79.1581),   // Start at Main Gate area
        const LatLng(12.9709, 79.1575),   // West along Amartya Sen Avenue
        const LatLng(12.9708, 79.1569),
        const LatLng(12.9715, 79.1565),   // Planck Avenue south (OSM node 12.9715, 79.1565)
        const LatLng(12.9720, 79.1566),   // Planck Ave heading north
        const LatLng(12.9727, 79.1566),   // OSM: 12.9727863, 79.1566301
        const LatLng(12.9733, 79.1567),   // OSM: 12.9733729, 79.1566844
        const LatLng(12.9737, 79.1567),   // Kissinger Road start (OSM: 12.9737163)
        const LatLng(12.9737, 79.1580),   // Along Kissinger Road heading east
        const LatLng(12.9737, 79.1590),   // OSM: 12.9737263, 79.1592694
        const LatLng(12.9737, 79.1598),
        const LatLng(12.9737, 79.1606),   // OSM: 12.9738016, 79.1606260
        const LatLng(12.9737, 79.1610),   // Kissinger Road SJT junction
        const LatLng(12.9728, 79.1610),   // OSM: 12.9728785, 79.1610405
        const LatLng(12.9725, 79.1610),   // SJT area
        const LatLng(12.9714, 79.1616),   // Jimmy Carter Road start (SJT)
        const LatLng(12.9716, 79.1626),   // OSM: 12.9716441, 79.1625961
        const LatLng(12.9718, 79.1636),   // OSM: 12.9718383, 79.1636412
        const LatLng(12.9720, 79.1647),   // OSM: 12.9720330, 79.1646760
      ],
    ),

    // ROUTE-03: Ladies Hostel → Planck Ave → Kissinger Road → TT → Fleming Roundabout → LH
    ShuttleRoute(
      routeId: 'ROUTE-03',
      code: 'R3',
      name: 'Ladies Hostel ➔ Academic Zone',
      description: 'Ladies Hostel via Planck Avenue and Kissinger Road to TT and Academic Zone',
      color: const Color(0xFF00E676),
      stops: [
        RouteStop(
          stopId: 'S3-1', name: 'Ladies Hostel (LH)',
          location: const LatLng(12.9744, 79.1568), order: 1, isMajorHub: true,
        ),
        RouteStop(
          stopId: 'S3-2', name: 'Kissinger Road West',
          location: const LatLng(12.9737, 79.1567), order: 2,
        ),
        RouteStop(
          stopId: 'S3-3', name: 'Technology Tower (TT)',
          location: const LatLng(12.9712, 79.1565), order: 3, isMajorHub: true,
        ),
        RouteStop(
          stopId: 'S3-4', name: 'Fleming Roundabout',
          location: const LatLng(12.9696, 79.1559), order: 4,
        ),
        RouteStop(
          stopId: 'S3-5', name: 'Anna Auditorium',
          location: const LatLng(12.9688, 79.1572), order: 5, isMajorHub: true,
        ),
      ],
      // Follows: LH → south on Planck Ave → Kissinger Rd west → TT area → Fleming roundabout → Khorana Ave → Anna Aud
      polyline: [
        const LatLng(12.9744, 79.1568),   // Ladies Hostel (OSM: 12.9744462, 79.1567819)
        const LatLng(12.9737, 79.1567),   // South on Planck Ave to Kissinger Road
        const LatLng(12.9733, 79.1567),
        const LatLng(12.9727, 79.1566),
        const LatLng(12.9720, 79.1566),
        const LatLng(12.9715, 79.1565),   // Planck Avenue south terminus
        const LatLng(12.9712, 79.1565),   // Technology Tower (TT area)
        const LatLng(12.9709, 79.1563),
        const LatLng(12.9708, 79.1557),
        const LatLng(12.9707, 79.1554),   // Heading toward Chandra Ave / Fleming Rd
        const LatLng(12.9704, 79.1554),
        const LatLng(12.9703, 79.1553),   // Chandra Ave junction
        const LatLng(12.9696, 79.1553),
        const LatLng(12.9696, 79.1559),   // Fleming Roundabout
        const LatLng(12.9696, 79.1566),
        const LatLng(12.9696, 79.1572),   // Khorana Avenue
        const LatLng(12.9688, 79.1572),   // Anna Auditorium area (King Road junction)
      ],
    ),
  ];

  // 3. Initial Buses (Exactly 3 buses matching 3 routes and 3 drivers, max capacity 35)
  static List<Bus> get initialBuses => [
    Bus(
      busId: 'BUS-01',
      busNumber: 'VIT Shuttle 01',
      routeId: 'ROUTE-01',
      routeName: 'Hostels ➔ TT ➔ Main Gate',
      driverId: 'user_driver_1',
      driverName: 'Murugan K.',
      active: true,
      capacity: 35,
      currentOccupancy: 12,
    ),
    Bus(
      busId: 'BUS-02',
      busNumber: 'VIT Shuttle 02',
      routeId: 'ROUTE-02',
      routeName: 'Main Gate ➔ SJT Express',
      driverId: 'user_driver_2',
      driverName: 'Ramesh Sundaram',
      active: true,
      capacity: 35,
      currentOccupancy: 8,
    ),
    Bus(
      busId: 'BUS-03',
      busNumber: 'VIT Shuttle 03',
      routeId: 'ROUTE-03',
      routeName: 'Ladies Hostel ➔ Academic Zone',
      driverId: 'user_driver_3',
      driverName: 'Anand Kumar',
      active: true,
      capacity: 35,
      currentOccupancy: 6,
    ),
  ];

  // 4. Initial Bus Locations — seeded at real campus road positions along the 3 routes
  static List<BusLocation> get initialLocations => [
    BusLocation(
      busId: 'BUS-01',
      latitude: 12.9693,
      longitude: 79.1553,   // On Chandra Avenue (Route 1)
      speed: 18.5,
      heading: 90.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      active: true,
      nextStop: 'Fleming Roundabout',
      etaMinutes: 2,
    ),
    BusLocation(
      busId: 'BUS-02',
      latitude: 12.9727,
      longitude: 79.1566,   // On Planck Avenue (Route 2)
      speed: 22.0,
      heading: 0.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      active: true,
      nextStop: 'SJT Junction',
      etaMinutes: 3,
    ),
    BusLocation(
      busId: 'BUS-03',
      latitude: 12.9737,
      longitude: 79.1567,   // On Kissinger Road / Planck Ave (Route 3)
      speed: 16.0,
      heading: 180.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      active: true,
      nextStop: 'Technology Tower (TT)',
      etaMinutes: 3,
    ),
  ];

  // 5. Initial Sample Ticket
  static List<Ticket> get initialTickets => [
    Ticket(
      ticketId: 'VS-98231',
      userId: 'user_student_1',
      userName: 'Rahul Sharma',
      busId: 'BUS-01',
      busNumber: 'VIT Shuttle 01',
      routeId: 'ROUTE-01',
      routeName: 'Hostels ➔ TT ➔ Main Gate',
      fromStop: 'Men\'s Hostel (Block D/E)',
      toStop: 'Technology Tower (TT)',
      amount: 20,
      status: TicketStatus.paid,
      paymentMethod: PaymentMethod.upi,
      qrData: 'VIT_TICKET_VS-98231_20_ACTIVE',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      validUntil: DateTime.now().add(const Duration(hours: 3)),
    ),
  ];
}

