import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/glass_card.dart';

class DriverScannerScreen extends StatefulWidget {
  const DriverScannerScreen({super.key});

  @override
  State<DriverScannerScreen> createState() => _DriverScannerScreenState();
}

class _DriverScannerScreenState extends State<DriverScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final TextEditingController _manualCodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _verifyCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _verifyCode(String rawCode) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final ticketProv = Provider.of<TicketProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final result = ticketProv.validateTicket(rawCode);
    final bool isValid = result['valid'] as bool;
    final String reason = result['reason'] as String;
    final Ticket? ticket = result['ticket'] as Ticket?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isValid ? AppTheme.success : AppTheme.error,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isValid ? AppTheme.success : AppTheme.error).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isValid ? AppTheme.success : AppTheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isValid ? 'VALID PASS ✓' : 'INVALID PASS ✗',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isValid ? AppTheme.success : AppTheme.error,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            if (ticket != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('PASSENGER', ticket.userName),
                    const Divider(color: AppTheme.cardBorder, height: 16),
                    _buildDetailRow('ROUTE', '${ticket.fromStop} ➔ ${ticket.toStop}'),
                    const Divider(color: AppTheme.cardBorder, height: 16),
                    _buildDetailRow('FARE PAID', '₹${ticket.amount} (${ticket.paymentMethod.name.toUpperCase()})'),
                    const Divider(color: AppTheme.cardBorder, height: 16),
                    _buildDetailRow('TICKET ID', ticket.ticketId),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (isValid && ticket != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await ticketProv.markTicketUsed(
                      ticket.ticketId,
                      auth.user?.uid ?? 'driver_01',
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passenger Boarded Successfully!'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'BOARD PASSENGER',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Scan Another Pass',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Passenger Pass',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Preview Area
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (kIsWeb)
                  Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded, size: 64, color: AppTheme.accent),
                          const SizedBox(height: 12),
                          Text(
                            'Camera active on mobile.\nUse manual code entry below for testing!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),

                // Viewfinder Target Box Overlay
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accent, width: 2.5),
                  ),
                ),

                // Help Tag
                Positioned(
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      'Align passenger QR code within frame',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Manual Entry Fallback Drawer (crucial for hackathons & web)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OR ENTER TICKET ID MANUALLY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualCodeController,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. VS-98231',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.keyboard_outlined, color: AppTheme.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: () {
                        final code = _manualCodeController.text.trim();
                        if (code.isNotEmpty) {
                          _verifyCode(code);
                        }
                      },
                      child: const Text('Verify'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Quick test code: VS-98231',
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentGlow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}


