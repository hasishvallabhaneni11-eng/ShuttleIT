import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'seed_data.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _firebaseAuth;
  FirebaseFirestore? _firestore;
  bool _firebaseReady = false;

  // Local fallback state
  AppUser? _currentUser;
  final StreamController<AppUser?> _userStreamController = StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get userStream => _userStreamController.stream;
  AppUser? get currentUser => _currentUser;
  bool get isFirebaseReady => _firebaseReady;

  Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firebaseAuth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        _firebaseReady = true;

        _firebaseAuth!.authStateChanges().listen((User? user) async {
          if (user == null) {
            _currentUser = null;
            _userStreamController.add(null);
          } else {
            final appUser = await _fetchUserProfile(user.uid);
            _currentUser = appUser;
            _userStreamController.add(appUser);
            // Start Firestore listeners now that user is authenticated
            DatabaseService().startListening();
          }
        });
        return;
      }
    } catch (_) {
      // Firebase not yet initialized via flutterfire configure, fallback to mock mode
    }

    _firebaseReady = false;
    // Default to student demo user for instant prototype access
    _currentUser = SeedData.initialUsers.first;
    _userStreamController.add(_currentUser);
  }

  Future<AppUser?> _fetchUserProfile(String uid) async {
    if (!_firebaseReady || _firestore == null) return null;
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, uid: uid);
      }
    } catch (_) {}
    return null;
  }

  // Sign In with email & password
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (_firebaseReady && _firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final profile = await _fetchUserProfile(credential.user!.uid);
        if (profile != null) {
          _currentUser = profile;
          _userStreamController.add(_currentUser);
          return profile;
        }
      } catch (e) {
        // If Firebase fails or user doesn't exist, check local seed fallback
      }
    }

    // Local / Demo auth fallback
    final matched = SeedData.initialUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () {
        final isDriver = email.contains('driver');
        final isAdmin = email.contains('admin');
        final busId = email.contains('03') || email.contains('3')
            ? 'BUS-03'
            : email.contains('02') || email.contains('2')
                ? 'BUS-02'
                : 'BUS-01';
        return AppUser(
          uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first,
          email: email,
          role: isDriver
              ? UserRole.driver
              : isAdmin
                  ? UserRole.admin
                  : UserRole.student,
          driverId: isDriver ? 'DRV-${busId.replaceAll('BUS-', '10')}' : null,
          assignedBusId: isDriver ? busId : null,
        );
      },
    );

    _currentUser = matched;
    _userStreamController.add(_currentUser);
    // Start Firestore listeners for demo mode too
    DatabaseService().startListening();
    return matched;
  }

  // Sign Up
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? regNumber,
    String? phone,
  }) async {
    final newUser = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      role: role,
      regNumber: regNumber?.trim(),
      phone: phone?.trim(),
    );

    if (_firebaseReady && _firebaseAuth != null && _firestore != null) {
      try {
        final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final createdUid = credential.user!.uid;
        final appUser = newUser.copyWith();
        final finalUser = AppUser(
          uid: createdUid,
          name: appUser.name,
          email: appUser.email,
          role: appUser.role,
          regNumber: appUser.regNumber,
          phone: appUser.phone,
        );
        await _firestore!.collection('users').doc(createdUid).set(finalUser.toMap());
        _currentUser = finalUser;
        _userStreamController.add(_currentUser);
        return finalUser;
      } catch (e) {
        // Fallback to local
      }
    }

    _currentUser = newUser;
    _userStreamController.add(_currentUser);
    return newUser;
  }

  // Quick switch role (Super convenient for testing & hackathon demo!)
  void switchDemoRole(UserRole role) {
    final user = SeedData.initialUsers.firstWhere(
      (u) => u.role == role,
      orElse: () => SeedData.initialUsers.first,
    );
    _currentUser = user;
    _userStreamController.add(_currentUser);
  }

  // Sign Out
  Future<void> signOut() async {
    if (_firebaseReady && _firebaseAuth != null) {
      try {
        await _firebaseAuth!.signOut();
      } catch (_) {}
    }
    _currentUser = null;
    _userStreamController.add(null);
  }
}

