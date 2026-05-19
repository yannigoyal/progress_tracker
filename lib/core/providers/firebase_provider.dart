import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseInitStatus {
  final bool isAvailable;
  final Object? error;

  const FirebaseInitStatus.available() : isAvailable = true, error = null;

  const FirebaseInitStatus.unavailable(this.error) : isAvailable = false;
}

final firebaseInitStatusProvider = Provider<FirebaseInitStatus>((ref) {
  return const FirebaseInitStatus.unavailable(
    'Firebase has not been initialized.',
  );
});
