import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ConnectivityService.onConnectivityChanged;
});

final isOnlineNowProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(isOnlineProvider);
  return asyncValue.value ?? ConnectivityService.isOnline;
});
