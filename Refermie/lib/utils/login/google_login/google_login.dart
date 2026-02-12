import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/login/login_status.dart';
import 'package:ebroker/utils/login/login_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin extends LoginSystem {
  // Use the singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  Future<void> init() async {
    // You must initialize the instance before using other methods
    await _googleSignIn.initialize();
  }

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());

      // Use authenticate() for sign-in, especially on platforms that support it
      // On web, you might need to use renderButton() or handle differently if supportsAuthenticate() is false
      final GoogleSignInAccount? googleSignInAccount;
      if (_googleSignIn.supportsAuthenticate()) {
        googleSignInAccount = await _googleSignIn.authenticate();
      } else {
        googleSignInAccount = null;
      }

      if (googleSignInAccount == null) {
        // User cancelled or login failed
        Widgets.hideLoder(context);
        HelperUtils.showSnackBarMessage(
          context,
          'googleLoginFailed',
        );
        return null;
      }

      final googleAuth = googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        authCredential,
      );
      emit(MSuccess(userCredential, type: 'google'));

      return userCredential;
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        emit(MFail('noInternet'.translate(context!)));
      } else {
        emit(
          MFail(e.message ?? 'googleLoginFailed'.translate(context!)),
        ); // Improved error handling
      }
    } on FirebaseAuthException catch (e) {
      emit(MFail(ErrorFilter.check(e.code)));
    } on Exception catch (_) {
      emit(MFail('googleLoginFailed'.translate(context!)));
    }
    return null;
  }

  @override
  void onEvent(MLoginState state) {
    if (kDebugMode) print('MLoginState is: $state');
  }
}
