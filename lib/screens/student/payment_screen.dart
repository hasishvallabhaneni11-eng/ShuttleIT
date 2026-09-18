import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/bus_model.dart';
import '../../models/route_model.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/gradient_button.dart';

class PaymentModal extends StatefulWidget {
  final ShuttleRoute? initialRoute;
  final Bus? initialBus;

  const PaymentModal({
    super.key,
    this.initialRoute,
    this.initialBus,
  });

  static Future<Ticket?> show(
    BuildContext context, {
    ShuttleRoute? initialRoute,
    Bus? initialBus,
  }) {
    return showModalBottomSheet<Ticket?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentModal(
        initialRoute: initialRoute,
        initialBus: initialBus,
      ),
    );
  }

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  late ShuttleRoute _selectedRoute;
  String? _fromStop;
  String? _toStop;
  PaymentMethod _paymentMethod = PaymentMethod.upi;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final busProv = Provider.of<BusProvider>(context, listen: false);
    _selectedRoute = widget.initialRoute ??
        busProv.routes.firstWhere(
          (r) => true,
          orElse: () => busProv.routes.first,
        );

    if (_selectedRoute.stops.isNotEmpty) {
      _fromStop = _selectedRoute.stops.first.name;
      _toStop = _selectedRoute.stops.length > 1
          ? _selectedRoute.stops.last.name
          : _selectedRoute.stops.first.name;
    }
  }

  Future<void> _processPayment() async {
    if (_fromStop == null || _toStop == null || _fromStop == _toStop) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select different Boarding and Destination stops'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Check if route is closed by driver or admin
    if (!_selectedRoute.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Route "${_selectedRoute.name}" is currently CLOSED by conductor/admin. Please select an active route.',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final busProv = Provider.of<BusProvider>(context, listen: false);
    final ticketProv = Provider.of<TicketProvider>(context, listen: false);

    final assignedBus = widget.initialBus ??
        busProv.activeBuses.firstWhere(
          (b) => b.routeId == _selectedRoute.routeId,
          orElse: () => busProv.buses.first,
        );

    // Show error if seats insufficient for requested quantity
    final availableSeats = assignedBus.capacity - assignedBus.currentOccupancy;
    if (availableSeats < _quantity) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              availableSeats <= 0
                  ? '${assignedBus.busNumber} is full (${assignedBus.capacity}/${assignedBus.capacity}). Please choose another route.'
                  : 'Only $availableSeats seat(s) available on ${assignedBus.busNumber}. Please select at most $availableSeats pass(es).',
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    Ticket? ticket;
    try {
      ticket = await ticketProv.bookTicket(
        userId: auth.user?.uid ?? 'guest_user',
        userName: auth.user?.name ?? 'Student Passenger',
        busId: assignedBus.busId,
        busNumber: assignedBus.busNumber,
        routeId: _selectedRoute.routeId,
        routeName: _selectedRoute.name,
        fromStop: _fromStop!,
        toStop: _toStop!,
        paymentMethod: _paymentMethod,
        quantity: _quantity,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    if (ticket != null) {
      Navigator.of(context).pop(ticket);
      _showSuccessDialog(ticket);
    }
  }

  void _showSuccessDialog(Ticket ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.primary, width: 1.2),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.black, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              '₹20 Payment Successful!',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Digital pass issued for ${ticket.fromStop} ➔ ${ticket.toStop}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ticket ID: ${ticket.ticketId}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'View My Pass',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busProv = Provider.of<BusProvider>(context);
    final ticketProv = Provider.of<TicketProvider>(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Shuttle Pass',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Instant Digital Boarding QR',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              // Fare Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '₹20.00',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Route Selector
          Text(
            'SELECT ROUTE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ShuttleRoute>(
                value: _selectedRoute,
                isExpanded: true,
                dropdownColor: AppTheme.surface,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                items: busProv.routes.map((r) {
                  return DropdownMenuItem<ShuttleRoute>(
                    value: r,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: r.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r.code,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: r.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            r.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newRoute) {
                  if (newRoute != null) {
                    setState(() {
                      _selectedRoute = newRoute;
                      if (newRoute.stops.isNotEmpty) {
                        _fromStop = newRoute.stops.first.name;
                        _toStop = newRoute.stops.last.name;
                      }
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Boarding & Destination
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOARDING STOP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _fromStop,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          items: _selectedRoute.stops.map((s) {
                            return DropdownMenuItem(
                              value: s.name,
                              child: Text(
                                s.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _fromStop = val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESTINATION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _toStop,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          items: _selectedRoute.stops.map((s) {
                            return DropdownMenuItem(
                              value: s.name,
                              child: Text(
                                s.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _toStop = val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Live Bus Occupancy
          Builder(builder: (context) {
            final assignedBus = busProv.activeBuses.firstWhere(
              (b) => b.routeId == _selectedRoute.routeId,
              orElse: () => busProv.buses.isNotEmpty ? busProv.buses.first : busProv.buses.first,
            );
            final fill = assignedBus.capacity > 0
                ? assignedBus.currentOccupancy / assignedBus.capacity
                : 0.0;
            final isFull = assignedBus.currentOccupancy >= assignedBus.capacity;
            final fillColor = isFull
                ? AppTheme.error
                : fill > 0.8
                    ? Colors.orange
                    : AppTheme.success;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFull ? AppTheme.error.withValues(alpha: 0.5) : AppTheme.cardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_seat_rounded, size: 14, color: fillColor),
                          const SizedBox(width: 6),
                          Text(
                            '${assignedBus.busNumber} — Occupancy',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isFull
                            ? 'FULL'
                            : '${assignedBus.currentOccupancy} / ${assignedBus.capacity} seats',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: fillColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fill.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppTheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(fillColor),
                    ),
                  ),
                  if (isFull)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '⚠️ This bus is full. Please choose a different route.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.error,
                        ),
                      ),
                    )
                  else if (fill > 0.8)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '⚡ Almost full — only ${assignedBus.capacity - assignedBus.currentOccupancy} seats left!',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // Payment Methods
          Text(
            'PAYMENT METHOD',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPaymentOption(
                method: PaymentMethod.upi,
                title: 'UPI / GPay',
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(width: 10),
              _buildPaymentOption(
                method: PaymentMethod.wallet,
                title: 'VIT Pay',
                icon: Icons.credit_card_rounded,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Number of Passes (Multiple Tickets Allowed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUMBER OF PASSES',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹20 flat rate per ticket',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        color: _quantity > 1 ? Colors.white : AppTheme.textMuted,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        color: _quantity < 5 ? Colors.white : AppTheme.textMuted,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        onPressed: _quantity < 5
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Pay Button
          GradientButton(
            text: ticketProv.isBooking
                ? 'Processing Payment...'
                : !_selectedRoute.isActive
                    ? 'Route Closed by Transport Control'
                    : 'Pay ₹${20 * _quantity} & Generate Pass (${_quantity}x)',
            isLoading: ticketProv.isBooking,
            gradient: _selectedRoute.isActive
                ? AppTheme.primaryGradient
                : const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
            icon: Icons.lock_outline_rounded,
            onPressed: _selectedRoute.isActive ? _processPayment : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


