import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/ticket_model.dart';
import 'seed_data.dart';
import 'web_sync/web_sync.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  FirebaseFirestore? _firestore;
  bool _firebaseReady = false;

  // Local Reactive State Stores
  final List<Bus> _buses = [];
  final List<ShuttleRoute> _routes = [];
  final List<Ticket> _tickets = [];

  final StreamController<List<Bus>> _busesController = StreamController<List<Bus>>.broadcast();
  final StreamController<List<ShuttleRoute>> _routesController = StreamController<List<ShuttleRoute>>.broadcast();
  final StreamController<List<Ticket>> _ticketsController = StreamController<List<Ticket>>.broadcast();

  Stream<List<Bus>> get busesStream => _busesController.stream;
  Stream<List<ShuttleRoute>> get routesStream => _routesController.stream;
  Stream<List<Ticket>> get ticketsStream => _ticketsController.stream;

  List<Bus> get currentBuses => List.unmodifiable(_buses);
  List<ShuttleRoute> get currentRoutes => List.unmodifiable(_routes);
  List<Ticket> get currentTickets => List.unmodifiable(_tickets);

  void init() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _firebaseReady = true;
      }
    } catch (_) {
      _firebaseReady = false;
    }

    // Seed local memory stores
    _buses.addAll(SeedData.initialBuses);
    _routes.addAll(SeedData.initialRoutes);
    _tickets.addAll(SeedData.initialTickets);

    // Check if web storage has latest tickets / routes
    _restoreFromWebStorage();

    // Listen for cross-tab updates on Web
    listenWebSync((key, value) {
      if (key == 'shuttleit_sync_tickets' && value != null) {
        _reloadTicketsFromWeb(value);
      } else if (key == 'shuttleit_sync_routes' && value != null) {
        _reloadRoutesFromWeb(value);
      }
    });

    _busesController.add(List.unmodifiable(_buses));
    _routesController.add(List.unmodifiable(_routes));
    _ticketsController.add(List.unmodifiable(_tickets));
  }

  void _restoreFromWebStorage() {
    try {
      final savedTickets = getWebSync('shuttleit_tickets_data');
      if (savedTickets != null && savedTickets.isNotEmpty) {
        final List list = jsonDecode(savedTickets);
        if (list.isNotEmpty) {
          _tickets.clear();
          for (final item in list) {
            _tickets.add(Ticket.fromMap(Map<String, dynamic>.from(item)));
          }
        }
      }
    } catch (_) {}
  }

  void _reloadTicketsFromWeb(String value) {
    try {
      final List list = jsonDecode(value);
      if (list.isNotEmpty) {
        _tickets.clear();
        for (final item in list) {
          _tickets.add(Ticket.fromMap(Map<String, dynamic>.from(item)));
        }
        _ticketsController.add(List.unmodifiable(_tickets));
      }
    } catch (_) {}
  }

  void _reloadRoutesFromWeb(String value) {
    try {
      final Map<String, dynamic> data = jsonDecode(value);
      if (data.containsKey('routes')) {
        final List rList = data['routes'];
        for (final rMap in rList) {
          final id = rMap['routeId'];
          final isActive = rMap['isActive'] as bool;
          final idx = _routes.indexWhere((r) => r.routeId == id);
          if (idx != -1) {
            _routes[idx] = _routes[idx].copyWith(isActive: isActive);
          }
        }
        _routesController.add(List.unmodifiable(_routes));
      }
      if (data.containsKey('buses')) {
        final List bList = data['buses'];
        for (final bMap in bList) {
          final id = bMap['busId'];
          final active = bMap['active'] as bool;
          final occ = bMap['currentOccupancy'] as int?;
          final idx = _buses.indexWhere((b) => b.busId == id);
          if (idx != -1) {
            _buses[idx] = _buses[idx].copyWith(
              active: active,
              currentOccupancy: occ ?? _buses[idx].currentOccupancy,
            );
          }
        }
        _busesController.add(List.unmodifiable(_buses));
      }
    } catch (_) {}
  }

  void _syncTicketsToWeb() {
    try {
      final list = _tickets.map((t) => t.toMap()).toList();
      final str = jsonEncode(list);
      notifyWebSync('shuttleit_tickets_data', str);
      notifyWebSync('shuttleit_sync_tickets', str);
    } catch (_) {}
  }

  void _syncRoutesToWeb() {
    try {
      final payload = {
        'routes': _routes.map((r) => {'routeId': r.routeId, 'isActive': r.isActive}).toList(),
        'buses': _buses.map((b) => {'busId': b.busId, 'active': b.active, 'currentOccupancy': b.currentOccupancy}).toList(),
      };
      notifyWebSync('shuttleit_sync_routes', jsonEncode(payload));
    } catch (_) {}
  }

  /// Call after user authenticates to start real-time Firestore sync
  void startListening() {
    _listenToFirestore();
  }

  void _listenToFirestore() {
    if (!_firebaseReady || _firestore == null) return;
    try {
      _firestore!.collection('buses').snapshots().listen((snap) {
        if (snap.docs.isNotEmpty) {
          _buses.clear();
          for (final doc in snap.docs) {
            _buses.add(Bus.fromMap(doc.data(), busId: doc.id));
          }
          _busesController.add(List.unmodifiable(_buses));
        }
      }, onError: (_) {});

      _firestore!.collection('routes').snapshots().listen((snap) {
        if (snap.docs.isNotEmpty) {
          _routes.clear();
          for (final doc in snap.docs) {
            _routes.add(ShuttleRoute.fromMap(doc.data(), routeId: doc.id));
          }
          _routesController.add(List.unmodifiable(_routes));
        }
      }, onError: (_) {});

      _firestore!.collection('tickets').snapshots().listen((snap) {
        if (snap.docs.isNotEmpty) {
          _tickets.clear();
          for (final doc in snap.docs) {
            _tickets.add(Ticket.fromMap(doc.data(), ticketId: doc.id));
          }
          _ticketsController.add(List.unmodifiable(_tickets));
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  // --- TICKET OPERATIONS ---

  Future<Ticket> createTicket({
    required String userId,
    required String userName,
    required String busId,
    required String busNumber,
    required String routeId,
    required String routeName,
    required String fromStop,
    required String toStop,
    PaymentMethod paymentMethod = PaymentMethod.upi,
    int amount = 20,
    int quantity = 1,
  }) async {
    // 1. Enforce route active status: cannot book on a closed route
    final routeIndex = _routes.indexWhere((r) => r.routeId == routeId);
    if (routeIndex != -1 && !_routes[routeIndex].isActive) {
      throw Exception('Route $routeName is currently CLOSED. Booking is unavailable.');
    }

    // 2. Enforce bus capacity limit for requested quantity
    final busIndex = _buses.indexWhere((b) => b.busId == busId);
    if (busIndex != -1) {
      final bus = _buses[busIndex];
      if (bus.currentOccupancy + quantity > bus.capacity) {
        final available = bus.capacity - bus.currentOccupancy;
        throw Exception(
          available <= 0
              ? '${bus.busNumber} is completely full (${bus.capacity}/${bus.capacity}).'
              : 'Only $available seat(s) available on ${bus.busNumber}. Please reduce quantity.',
        );
      }
    }

    final totalAmount = amount * quantity;
    final ticketId = 'VS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final now = DateTime.now();

    final ticket = Ticket(
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      busId: busId,
      busNumber: busNumber,
      routeId: routeId,
      routeName: routeName,
      fromStop: fromStop,
      toStop: toStop,
      amount: totalAmount,
      status: TicketStatus.paid,
      paymentMethod: paymentMethod,
      qrData: 'VIT_SHUTTLE_${ticketId}_Q$quantity',
      createdAt: now,
      validUntil: now.add(const Duration(hours: 4)),
    );

    // Save locally
    _tickets.insert(0, ticket);
    _ticketsController.add(List.unmodifiable(_tickets));

    // Increment bus occupancy by quantity
    await _incrementOccupancy(busId, count: quantity);

    // Sync across tabs immediately
    _syncTicketsToWeb();

    // Save to Firestore if available
    if (_firebaseReady && _firestore != null) {
      try {
        await _firestore!.collection('tickets').doc(ticketId).set(ticket.toMap());
      } catch (_) {}
    }

    return ticket;
  }

  /// Increment occupancy when a student books a ticket
  Future<void> _incrementOccupancy(String busId, {int count = 1}) async {
    final index = _buses.indexWhere((b) => b.busId == busId);
    if (index != -1) {
      final bus = _buses[index];
      final newOccupancy = (bus.currentOccupancy + count).clamp(0, bus.capacity);
      _buses[index] = bus.copyWith(currentOccupancy: newOccupancy);
      _busesController.add(List.unmodifiable(_buses));
      _syncRoutesToWeb();
      if (_firebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('buses').doc(busId).update({'currentOccupancy': newOccupancy});
        } catch (_) {}
      }
    }
  }

  /// Decrement occupancy when driver scans / validates a ticket
  Future<void> _decrementOccupancy(String busId, {int count = 1}) async {
    final index = _buses.indexWhere((b) => b.busId == busId);
    if (index != -1) {
      final bus = _buses[index];
      final newOccupancy = (bus.currentOccupancy - count).clamp(0, bus.capacity);
      _buses[index] = bus.copyWith(currentOccupancy: newOccupancy);
      _busesController.add(List.unmodifiable(_buses));
      _syncRoutesToWeb();
      if (_firebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('buses').doc(busId).update({'currentOccupancy': newOccupancy});
        } catch (_) {}
      }
    }
  }

  // Driver Validation Result
  Map<String, dynamic> validateTicket(String codeOrQr) {
    String searchId = codeOrQr.trim();
    if (searchId.contains('VIT_SHUTTLE_')) {
      searchId = searchId.replaceAll('VIT_SHUTTLE_', '');
    }
    // Strip quantity suffix if present (e.g. _Q2)
    if (searchId.contains('_Q')) {
      searchId = searchId.split('_Q').first;
    }

    final index = _tickets.indexWhere(
      (t) =>
          t.ticketId.toUpperCase() == searchId.toUpperCase() ||
          t.qrData == codeOrQr ||
          t.qrData.startsWith('VIT_SHUTTLE_$searchId'),
    );

    if (index == -1) {
      return {
        'valid': false,
        'reason': 'Ticket not found. Invalid code or unverified pass.',
        'ticket': null,
      };
    }

    final ticket = _tickets[index];

    if (ticket.status == TicketStatus.used) {
      return {
        'valid': false,
        'reason': 'Ticket already USED on ${ticket.usedAt?.hour.toString().padLeft(2, '0')}:${ticket.usedAt?.minute.toString().padLeft(2, '0')}. Duplicate boarding rejected.',
        'ticket': ticket,
      };
    }

    if (ticket.isExpired) {
      return {
        'valid': false,
        'reason': 'Ticket EXPIRED. Validity has ended.',
        'ticket': ticket,
      };
    }

    return {
      'valid': true,
      'reason': 'Valid ₹${ticket.amount} Travel Pass',
      'ticket': ticket,
    };
  }

  Future<bool> markTicketUsed(String ticketId, String driverId) async {
    final index = _tickets.indexWhere((t) => t.ticketId == ticketId);
    if (index != -1) {
      final ticket = _tickets[index];
      final updated = ticket.copyWith(
        status: TicketStatus.used,
        usedAt: DateTime.now(),
        scannedByDriverId: driverId,
      );
      _tickets[index] = updated;
      _ticketsController.add(List.unmodifiable(_tickets));

      // Decrement occupancy when driver scans a ticket
      await _decrementOccupancy(ticket.busId);

      _syncTicketsToWeb();

      if (_firebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('tickets').doc(ticketId).update({
            'status': TicketStatus.used.name,
            'usedAt': DateTime.now().toIso8601String(),
            'scannedByDriverId': driverId,
          });
        } catch (_) {}
      }
      return true;
    }
    return false;
  }

  // Cash ₹20 pass issued by driver
  Future<Ticket> issueCashTicket({
    required String driverId,
    required String busId,
    required String busNumber,
    required String routeId,
    required String routeName,
    required String fromStop,
    required String toStop,
    int quantity = 1,
  }) async {
    return await createTicket(
      userId: 'cash_passenger_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'Campus Passenger (Cash)',
      busId: busId,
      busNumber: busNumber,
      routeId: routeId,
      routeName: routeName,
      fromStop: fromStop,
      toStop: toStop,
      paymentMethod: PaymentMethod.cash,
      amount: 20,
      quantity: quantity,
    );
  }

  // --- ROUTE OPERATIONS (Open / Close Routes) ---

  Future<void> toggleRouteActive(String routeId, bool active) async {
    final rIndex = _routes.indexWhere((r) => r.routeId == routeId);
    if (rIndex != -1) {
      _routes[rIndex] = _routes[rIndex].copyWith(isActive: active);
      _routesController.add(List.unmodifiable(_routes));

      // Synchronize associated buses with route state
      for (int i = 0; i < _buses.length; i++) {
        if (_buses[i].routeId == routeId) {
          _buses[i] = _buses[i].copyWith(active: active);
        }
      }
      _busesController.add(List.unmodifiable(_buses));

      _syncRoutesToWeb();

      if (_firebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('routes').doc(routeId).update({'isActive': active});
          for (final b in _buses.where((b) => b.routeId == routeId)) {
            await _firestore!.collection('buses').doc(b.busId).update({'active': active});
          }
        } catch (_) {}
      }
    }
  }

  // --- BUS OPERATIONS ---

  Future<void> toggleBusActive(String busId, bool active) async {
    final index = _buses.indexWhere((b) => b.busId == busId);
    if (index != -1) {
      _buses[index] = _buses[index].copyWith(active: active);
      _busesController.add(List.unmodifiable(_buses));
      _syncRoutesToWeb();

      if (_firebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('buses').doc(busId).update({'active': active});
        } catch (_) {}
      }
    }
  }

  Future<void> assignDriverToBus(String busId, String driverId, String driverName) async {
    final index = _buses.indexWhere((b) => b.busId == busId);
    if (index != -1) {
      _buses[index] = _buses[index].copyWith(driverId: driverId, driverName: driverName);
      _busesController.add(List.unmodifiable(_buses));

      if (_firebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('buses').doc(busId).update({
            'driverId': driverId,
            'driverName': driverName,
          });
        } catch (_) {}
      }
    }
  }

  // --- STATS FOR ADMIN DASHBOARD ---
  Map<String, dynamic> getAdminStats() {
    final activeBusesCount = _buses.where((b) => b.active).length;
    final totalTicketsToday = _tickets.length;
    final totalRevenue = _tickets.fold<int>(0, (total, t) => total + t.amount);
    final totalBoarded = _tickets.where((t) => t.status == TicketStatus.used).length;

    return {
      'activeBuses': activeBusesCount,
      'totalBuses': _buses.length,
      'todayTrips': totalTicketsToday,
      'todayRevenue': totalRevenue,
      'boardedPassengers': totalBoarded,
    };
  }
}

