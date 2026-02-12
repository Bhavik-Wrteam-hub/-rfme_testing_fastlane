import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum LoginType {
  google('0'),
  phone('1'),
  apple('2'),
  email('3')
  ;

  const LoginType(this.value);

  final String value;
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static int? forceResendingToken;
  Future<Map<String, dynamic>> loginWithApi({
    required LoginType type,
    required String phone,
    required String countryCode,
    required String uid,
    String? email,
    String? name,
  }) async {
    try {
      var token = '';
      if (Platform.isIOS) {
        token = await FirebaseMessaging.instance.getAPNSToken() ?? '';
      } else {
        token = await FirebaseMessaging.instance.getToken() ?? '';
      }

      final parameters = <String, String>{
        Api.mobile: phone,
        'country_code': countryCode,
        Api.authId: uid,
        'email': ?email,
        'name': ?name,
        'fcm_id': token,
        Api.type: type.value,
      };

      if (type == LoginType.phone) {
        parameters.remove('email');
      }

      final response = await Api.post(
        url: Api.apiLogin,
        parameter: parameters,
        useAuthToken: false,
      );
      log('Response of login with API: $response', name: 'loginWithApi');
      if (response['error'] == true) {
        return {
          'token': '',
          'data': response,
        };
      }

      return {
        'token': response['token'],
        'data': response['data'],
      };
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
    required LoginType type,
  }) async {
    var token = '';
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken() ?? '';
    } else {
      token = await FirebaseMessaging.instance.getToken() ?? '';
    }
    final parameters = {
      'email': email,
      'password': password,
      Api.type: type.value,
      'fcm_id': token,
    };
    final response = await Api.post(
      url: Api.apiLogin,
      parameter: parameters,
      useAuthToken: false,
    );
    if (response['error'] == true) {
      return response;
    }

    return {
      'token': response['token'],
      'data': response['data'],
    };
  }

  Future<Map<String, dynamic>> loginWithPhone({
    required String phone,
    required String password,
    required String countryCode,
    required LoginType type,
  }) async {
    var token = '';
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken() ?? '';
    } else {
      token = await FirebaseMessaging.instance.getToken() ?? '';
    }
    final parameters = {
      Api.mobile: phone,
      'country_code': countryCode,
      'password': password,
      Api.type: type.value,
      'fcm_id': token,
    };
    final response = await Api.post(
      url: Api.apiLogin,
      parameter: parameters,
      useAuthToken: false,
    );
    if (response['error'] == true) {
      return response;
    }

    return {
      'token': response['token'],
      'data': response['data'],
    };
  }

  Future<Map<String, dynamic>> sendForgotPasswordEmail({
    required String email,
  }) async {
    try {
      final parameters = {
        'email': email,
      };
      final response = await Api.get(
        url: Api.apiForgotPassword,
        queryParameters: parameters,
      );
      return {
        'error': response['error'],
        'message': response['message'],
      };
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> checkNumberPasswordExists({
    required String mobile,
    required String countryCode,
  }) async {
    try {
      final parameters = {
        'mobile': mobile,
        'country_code': countryCode,
      };
      final response = await Api.get(
        url: Api.checkNumberPasswordExists,
        queryParameters: parameters,
        useAuthToken: false,
      );

      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateNumberPassword({
    required String firebaseId,
    required String mobile,
    required String countryCode,
    required String password,
    required String rePassword,
  }) async {
    try {
      final parameters = {
        'firebase_id': firebaseId,
        'mobile': mobile,
        'country_code': countryCode,
        'password': password,
        're_password': rePassword,
      };
      final response = await Api.post(
        url: Api.updateNumberPassword,
        parameter: parameters,
        useAuthToken: false,
      );
      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> sendEmailOTP({
    required String email,
    required String name,
    required String password,
    required String phoneNumber,
    required String countryCode,
    required String confirmPassword,
  }) async {
    try {
      final parameters = {
        'email': email,
        'name': name,
        'password': password,
        'mobile': phoneNumber,
        'country_code': countryCode,
        're_password': confirmPassword,
        'type':
            LoginType.email.value, // Add type parameter for email registration
      };
      final response = await Api.post(
        url: Api.userRegister,
        parameter: parameters,
        useAuthToken: false,
      );
      if (response['error'] == true) {
        return response;
      }
      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> sendPhoneRegistrationOTP({
    required String phoneNumber,
    required String countryCode,
    required String name,
    required String password,
    required String confirmPassword,
    String? email,
  }) async {
    try {
      final parameters = {
        'mobile': phoneNumber,
        'country_code': countryCode,
        'name': name,
        'password': password,
        're_password': confirmPassword,
        'type':
            LoginType.phone.value, // Add type parameter for phone registration
        if (email != null && email.isNotEmpty) 'email': email,
      };
      final response = await Api.post(
        url: Api.userRegister,
        parameter: parameters,
        useAuthToken: false,
      );
      if (response['error'] == true) {
        return response;
      }
      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> resendEmailOTP({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Api.get(
        url: Api.apiGetOtp,
        useAuthToken: false,
        queryParameters: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> sendOTP({
    required String phoneNumber,
    required String countryCode,
    required dynamic Function(String verificationId) onCodeSent,
    dynamic Function(dynamic e)? onError,
  }) async {
    if (AppSettings.otpServiceProvider == 'twilio') {
      await Api.get(
        url: Api.apiGetOtp,
        queryParameters: {
          'number': phoneNumber,
          'country_code': countryCode,
        },
      );
      onCodeSent.call(phoneNumber);
    } else if (AppSettings.otpServiceProvider == 'firebase') {
      await FirebaseAuth.instance.verifyPhoneNumber(
        timeout: Duration(
          seconds: Constant.otpTimeOutSecond,
        ),
        phoneNumber: '+$countryCode$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          onError?.call(ApiException(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          forceResendingToken = resendToken;
          onCodeSent.call(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        forceResendingToken: forceResendingToken,
      );
    }
  }

  Future<UserCredential> verifyFirebaseOTP({
    required String otpVerificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: otpVerificationId,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on Exception catch (e) {
      throw ApiException(e);
    }
  }

  Future<dynamic> verifyTwilioOTP({
    required String otp,
    required String number,
    required String countryCode,
  }) async {
    try {
      String? authId;
      final credential = await Api.get(
        url: Api.apiVerifyOtp,
        queryParameters: {
          'auth_id': authId,
          'country_code': countryCode,
          'number': number,
          'otp': otp,
        },
      );
      return credential;
    } on Exception catch (e) {
      throw ApiException(e);
    }
  }

  Future<dynamic> verifyEmailOTP({
    required String otp,
    required String email,
  }) async {
    try {
      final credential = await Api.get(
        url: Api.apiVerifyOtp,
        queryParameters: {
          'email': email,
          'otp': otp,
        },
      );
      return credential;
    } on Exception catch (e) {
      throw ApiException(e);
    }
  }

  Future<Map<String, dynamic>> registerUserWithPhone({
    required String firebaseId,
    required String mobile,
    required String countryCode,
    required String password,
    required String rePassword,
    required String name,
    String? email,
  }) async {
    try {
      final parameters = {
        'firebase_id': firebaseId,
        'mobile': mobile,
        'country_code': countryCode,
        'password': password,
        're_password': rePassword,
        'name': name,
        'type': LoginType.phone.value,
        if (email != null && email.isNotEmpty) 'email': email,
      };
      final response = await Api.post(
        url: Api.userRegister,
        parameter: parameters,
        useAuthToken: false,
      );
      return response;
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> beforeLogout() async {
    var token = '';
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken() ?? '';
    } else {
      token = await FirebaseMessaging.instance.getToken() ?? '';
    }
    await Api.post(
      url: Api.apiBeforeLogout,
      parameter: {
        Api.fcmId: token,
      },
    );
  }
}
