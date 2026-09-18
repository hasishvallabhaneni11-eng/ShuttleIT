enum TicketStatus { paid, used, expired, cancelled }
enum PaymentMethod { upi, cash, wallet }

class Ticket {
  final String ticketId;
  final String userId;
  final String userName;
  final String busId;
  final String busNumber;
  final String routeId;
  final String routeName;
  final String fromStop;
  final String toStop;
  final int amount; // ₹20
  final TicketStatus status;
  final PaymentMethod paymentMethod;
  final String qrData;
  final DateTime createdAt;
  final DateTime validUntil;
  final DateTime? usedAt;
  final String? scannedByDriverId;

  Ticket({
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.busId,
    required this.busNumber,
    required this.routeId,
    required this.routeName,
    required this.fromStop,
    required this.toStop,
    this.amount = 20,
    this.status = TicketStatus.paid,
    this.paymentMethod = PaymentMethod.upi,
    required this.qrData,
    required this.createdAt,
    required this.validUntil,
    this.usedAt,
    this.scannedByDriverId,
  });

  bool get isValid => status == TicketStatus.paid && DateTime.now().isBefore(validUntil);
  bool get isUsed => status == TicketStatus.used;
  bool get isExpired => status == TicketStatus.expired || DateTime.now().isAfter(validUntil);

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'userName': userName,
      'busId': busId,
      'busNumber': busNumber,
      'routeId': routeId,
      'routeName': routeName,
      'fromStop': fromStop,
      'toStop': toStop,
      'amount': amount,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'qrData': qrData,
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'scannedByDriverId': scannedByDriverId,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map, {String? ticketId}) {
    return Ticket(
      ticketId: ticketId ?? map['ticketId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Passenger',
      busId: map['busId'] ?? '',
      busNumber: map['busNumber'] ?? 'Shuttle',
      routeId: map['routeId'] ?? '',
      routeName: map['routeName'] ?? '',
      fromStop: map['fromStop'] ?? '',
      toStop: map['toStop'] ?? '',
      amount: map['amount'] ?? 20,
      status: TicketStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TicketStatus.paid,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.upi,
      ),
      qrData: map['qrData'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      validUntil: map['validUntil'] != null
          ? DateTime.parse(map['validUntil'])
          : DateTime.now().add(const Duration(hours: 4)),
      usedAt: map['usedAt'] != null ? DateTime.parse(map['usedAt']) : null,
      scannedByDriverId: map['scannedByDriverId'],
    );
  }

  Ticket copyWith({
    TicketStatus? status,
    DateTime? usedAt,
    String? scannedByDriverId,
  }) {
    return Ticket(
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      busId: busId,
      busNumber: busNumber,
      routeId: routeId,
      routeName: routeName,
      fromStop: fromStop,
      toStop: toStop,
      amount: amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      qrData: qrData,
      createdAt: createdAt,
      validUntil: validUntil,
      usedAt: usedAt ?? this.usedAt,
      scannedByDriverId: scannedByDriverId ?? this.scannedByDriverId,
    );
  }
}

