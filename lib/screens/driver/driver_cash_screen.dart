import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/bus_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class DriverCashScreen extends StatefulWidget {
  final Bus assignedBus;

  const DriverCashScreen({super.key, required this.assignedBus});

  @override
  State<DriverCashScreen> createState() => _DriverCashScreenState();
}

class _DriverCashScreenState extends State<DriverCashScreen> {
  String? _fromStop;
  String? _toStop;
  bool _isIssuing = false;

  @override
  void initState() {
    super.initState();
    final busProv = Provider.of<BusProvider>(context, listen: false);
    final route = busProv.routes.firstWhere(
      (r) => r.routeId == widget.assignedBus.routeId,
      orElse: () => busProv.routes.first,
    );

    if (route.stops.isNotEmpty) {
      _fromStop = route.stops.first.name;
      _toStop = route.stops.last.name;
    }
  }

  Future<void> _handleCashTicket() async {
    if (_fromStop == null || _toStop == null || _fromStop == _toStop) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select valid boarding and destination stops'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isIssuing = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final busProv = Provider.of<BusProvider>(context, listen: false);
    final ticketProv = Provider.of<TicketProvider>(context, listen: false);

    final route = busProv.routes.firstWhere(
      (r) => r.routeId == widget.assignedBus.routeId,
      orElse: () => busProv.routes.first,
    );

    final ticket = await ticketProv.issueCashTicket(
      driverId: auth.user?.uid ?? 'driver_01',
      busId: widget.assignedBus.busId,
      busNumber: widget.assignedBus.busNumber,
      routeId: route.routeId,
      routeName: route.name,
      fromStop: _fromStop!,
      toStop: _toStop!,
    );

    // Immediately mark as used since passenger is already boarding with cash!
    await ticketProv.markTicketUsed(ticket.ticketId, auth.user?.uid ?? 'driver_01');

    setState(() => _isIssuing = false);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.success, width: 1.2),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.black, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              '₹20 Cash Received',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Passenger successfully boarded for:\n$_fromStop ➔ $_toStop',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            Text(
              'Transaction ID: ${ticket.ticketId}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done & Return to Dashboard', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busProv = Provider.of<BusProvider>(context);
    final route = busProv.routes.firstWhere(
      (r) => r.routeId == widget.assignedBus.routeId,
      orElse: () => busProv.routes.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Collect Cash ₹20',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.surfaceGradient,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Banner
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_bus_rounded, color: AppTheme.accent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.assignedBus.busNumber,
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        route.name,
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'PASSENGER TRIP DETAILS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // From stop
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _fromStop,
                  isExpanded: true,
                  dropdownColor: AppTheme.surface,
                  items: route.stops.map((s) {
                    return DropdownMenuItem(
                      value: s.name,
                      child: Text('From: ${s.name}', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _fromStop = v),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // To stop
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _toStop,
                  isExpanded: true,
                  dropdownColor: AppTheme.surface,
                  items: route.stops.map((s) {
                    return DropdownMenuItem(
                      value: s.name,
                      child: Text('To: ${s.name}', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _toStop = v),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Amount summary card
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CASH AMOUNT',
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Standard Campus Fare',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  Text(
                    '₹20',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Confirm Button
            GradientButton(
              text: 'Collect ₹20 Cash & Board',
              isLoading: _isIssuing,
              icon: Icons.payments_outlined,
              gradient: AppTheme.accentGradient,
              onPressed: _handleCashTicket,
            ),
          ],
        ),
      ),
    );
  }
}


