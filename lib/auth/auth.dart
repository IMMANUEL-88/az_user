import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to Login',
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Error during local authentication: ${e.message}');
      return false;
    }
  }
}
