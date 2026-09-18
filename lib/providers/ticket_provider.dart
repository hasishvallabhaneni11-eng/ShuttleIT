import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/database_service.dart';

class TicketProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Ticket> _tickets = [];
  bool _isBooking = false;
  String? _lastBookedTicketId;

  List<Ticket> get tickets => _tickets;
  bool get isBooking => _isBooking;
  String? get lastBookedTicketId => _lastBookedTicketId;

  TicketProvider() {
    _init();
  }

  void _init() {
    _tickets = _dbService.currentTickets;
    _dbService.ticketsStream.listen((list) {
      _tickets = list;
      notifyListeners();
    });
  }

  List<Ticket> getUserTickets(String userId) {
    return _tickets.where((t) => t.userId == userId).toList();
  }

  Ticket? getActivePass(String userId) {
    final list = _tickets.where((t) => t.userId == userId && t.isValid).toList();
    return list.isNotEmpty ? list.first : null;
  }

  Future<Ticket?> bookTicket({
    required String userId,
    required String userName,
    required String busId,
    required String busNumber,
    required String routeId,
    required String routeName,
    required String fromStop,
    required String toStop,
    PaymentMethod paymentMethod = PaymentMethod.upi,
    int quantity = 1,
  }) async {
    _isBooking = true;
    notifyListeners();

    // Realistic short delay for payment processing animation
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final ticket = await _dbService.createTicket(
        userId: userId,
        userName: userName,
        busId: busId,
        busNumber: busNumber,
        routeId: routeId,
        routeName: routeName,
        fromStop: fromStop,
        toStop: toStop,
        paymentMethod: paymentMethod,
        amount: 20,
        quantity: quantity,
      );

      _lastBookedTicketId = ticket.ticketId;
      _isBooking = false;
      notifyListeners();
      return ticket;
    } catch (e) {
      _isBooking = false;
      notifyListeners();
      rethrow;
    }
  }

  Map<String, dynamic> validateTicket(String codeOrQr) {
    return _dbService.validateTicket(codeOrQr);
  }

  Future<bool> markTicketUsed(String ticketId, String driverId) async {
    final result = await _dbService.markTicketUsed(ticketId, driverId);
    notifyListeners();
    return result;
  }

  Future<Ticket> issueCashTicket({
    required String driverId,
    required String busId,
    required String busNumber,
    required String routeId,
    required String routeName,
    required String fromStop,
    required String toStop,
  }) async {
    final ticket = await _dbService.issueCashTicket(
      driverId: driverId,
      busId: busId,
      busNumber: busNumber,
      routeId: routeId,
      routeName: routeName,
      fromStop: fromStop,
      toStop: toStop,
    );
    notifyListeners();
    return ticket;
  }

  Map<String, dynamic> getAdminStats() {
    return _dbService.getAdminStats();
  }
}

