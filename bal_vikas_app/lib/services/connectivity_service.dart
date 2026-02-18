import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_service.dart';

class ConnectivityService {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _isOnline = true;
  static bool _forceOffline = false;

  /// When forceOffline is true, isOnline always returns false.
  static bool get forceOffline => _forceOffline;
  static set forceOffline(bool value) {
    _forceOffline = value;
    _controller.add(isOnline);
  }

  static bool get isOnline => _forceOffline ? false : _isOnline;

  static final _controller = StreamController<bool>.broadcast();
  static Stream<bool> get onConnectivityChanged => _controller.stream;

  static void startListening() {
    if (kIsWeb) return; // connectivity_plus not reliable on web; assume online

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      _controller.add(_isOnline);

      // If we just came back online, trigger sync
      if (!wasOnline && _isOnline) {
        SyncService.processQueue();
      }
    });

    // Check initial state
    Connectivity().checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      _controller.add(_isOnline);
    });
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
