import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'student/student_home.dart';
import 'driver/driver_home.dart';
import 'admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: AppConstants.demoStudentEmail);
  final _passwordController = TextEditingController(text: AppConstants.demoStudentPassword);
  final _nameController = TextEditingController();
  final _regNumberController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }

  void _fillCredentials({
    required String email,
    required String password,
    required UserRole role,
  }) {
    setState(() {
      _selectedRole = role;
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  void _fillDemoCredentials(UserRole role) {
    switch (role) {
      case UserRole.student:
        _fillCredentials(
          email: AppConstants.demoStudentEmail,
          password: AppConstants.demoStudentPassword,
          role: UserRole.student,
        );
        break;
      case UserRole.driver:
        _fillCredentials(
          email: AppConstants.demoDriver1Email,
          password: AppConstants.demoDriver1Password,
          role: UserRole.driver,
        );
        break;
      case UserRole.admin:
        _fillCredentials(
          email: AppConstants.demoAdminEmail,
          password: AppConstants.demoAdminPassword,
          role: UserRole.admin,
        );
        break;
    }
  }

  Future<void> _handleAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    bool success = false;
    if (_isSignUp) {
      if (_nameController.text.trim().isEmpty) {
        _showSnackBar('Please enter your full name');
        return;
      }
      success = await auth.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        regNumber: _regNumberController.text.trim(),
      );
    } else {
      success = await auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      Widget destination;
      switch (auth.currentRole) {
        case UserRole.student:
          destination = const StudentHome();
          break;
        case UserRole.driver:
          destination = const DriverHome();
          break;
        case UserRole.admin:
          destination = const AdminDashboard();
          break;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {
      _showSnackBar(auth.errorMessage ?? 'Authentication failed. Please check credentials.');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.surfaceGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Header
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      size: 38,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ShuttleIT',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time Campus Transit & Passes',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Demo Autofill Bar (Hackathon showcase feature)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        _buildRoleTab(UserRole.student, 'Student', Icons.school_rounded),
                        _buildRoleTab(UserRole.driver, 'Driver', Icons.drive_eta_rounded),
                        _buildRoleTab(UserRole.admin, 'Admin', Icons.admin_panel_settings_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Main Form Card
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_isSignUp) ...[
                          TextField(
                            controller: _nameController,
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primary),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (_selectedRole == UserRole.student) ...[
                            TextField(
                              controller: _regNumberController,
                              style: GoogleFonts.inter(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Registration Number (e.g. 22BCE1001)',
                                prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primary),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'VIT Email Address',
                            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                          ),
                        ),

                        const SizedBox(height: 24),

                        GradientButton(
                          text: _isSignUp ? 'Create Account' : 'Sign In as ${_selectedRole.name.toUpperCase()}',
                          isLoading: auth.isLoading,
                          gradient: _selectedRole == UserRole.driver
                              ? AppTheme.accentGradient
                              : AppTheme.primaryGradient,
                          onPressed: _handleAuth,
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _isSignUp
                                        ? 'Already have an account? '
                                        : "Don't have an account? ",
                                    style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _isSignUp ? 'Sign In' : 'Sign Up',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Demo 1-Tap Buttons for 3 Drivers, Admin, and Student
                  Text(
                    '⚡ 1-TAP FIXED CREDENTIALS LOGIN',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFixedLoginChip(
                        label: 'Student',
                        email: AppConstants.demoStudentEmail,
                        password: AppConstants.demoStudentPassword,
                        role: UserRole.student,
                        color: AppTheme.primary,
                      ),
                      _buildFixedLoginChip(
                        label: 'Driver 1 (R1)',
                        email: AppConstants.demoDriver1Email,
                        password: AppConstants.demoDriver1Password,
                        role: UserRole.driver,
                        color: const Color(0xFF00D2FF),
                      ),
                      _buildFixedLoginChip(
                        label: 'Driver 2 (R2)',
                        email: AppConstants.demoDriver2Email,
                        password: AppConstants.demoDriver2Password,
                        role: UserRole.driver,
                        color: const Color(0xFFFF9100),
                      ),
                      _buildFixedLoginChip(
                        label: 'Driver 3 (R3)',
                        email: AppConstants.demoDriver3Email,
                        password: AppConstants.demoDriver3Password,
                        role: UserRole.driver,
                        color: const Color(0xFF00E676),
                      ),
                      _buildFixedLoginChip(
                        label: 'Admin',
                        email: AppConstants.demoAdminEmail,
                        password: AppConstants.demoAdminPassword,
                        role: UserRole.admin,
                        color: const Color(0xFFE040FB),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Fixed Credentials Reference Card
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.vpn_key_rounded, size: 16, color: AppTheme.accent),
                            const SizedBox(width: 8),
                            Text(
                              'FIXED CREDENTIALS REFERENCE',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accent,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildCredentialRow('Driver 01 (R1 - Shuttle 01)', AppConstants.demoDriver1Email, 'password123'),
                        _buildCredentialRow('Driver 02 (R2 - Shuttle 02)', AppConstants.demoDriver2Email, 'password123'),
                        _buildCredentialRow('Driver 03 (R3 - Shuttle 03)', AppConstants.demoDriver3Email, 'password123'),
                        _buildCredentialRow('Admin Dashboard', AppConstants.demoAdminEmail, 'password123'),
                        _buildCredentialRow('Student Account', AppConstants.demoStudentEmail, 'password123'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String roleLabel, String email, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            roleLabel,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          Text(
            '$email / $password',
            style: GoogleFonts.firaCode(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _fillDemoCredentials(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surfaceLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: role == UserRole.driver ? AppTheme.accent : AppTheme.primary,
                    width: 1.2,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (role == UserRole.driver ? AppTheme.accent : AppTheme.primary)
                    : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedLoginChip({
    required String label,
    required String email,
    required String password,
    required UserRole role,
    required Color color,
  }) {
    return ActionChip(
      onPressed: () {
        _fillCredentials(email: email, password: password, role: role);
        _handleAuth();
      },
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(
          role == UserRole.student
              ? Icons.school
              : role == UserRole.driver
                  ? Icons.directions_bus
                  : Icons.admin_panel_settings,
          size: 14,
          color: color,
        ),
      ),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppTheme.surfaceLight.withValues(alpha: 0.8),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}



