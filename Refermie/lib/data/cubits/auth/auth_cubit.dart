import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthProgress extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.isAuthenticated});
  bool isAuthenticated = false;
}

class AuthFailure extends AuthState {
  AuthFailure(this.errorMessage);
  final String errorMessage;
}

class AuthCubit extends Cubit<AuthState> {
  //late String name, email, profile, address;
  AuthCubit() : super(AuthInitial()) {
    // checkIsAuthenticated();
  }
  void checkIsAuthenticated() {
    if (HiveUtils.isUserAuthenticated()) {
      //setUserData();
      emit(Authenticated(isAuthenticated: true));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<Map<String, dynamic>> updateUserData({
    String? name,
    String? email,
    String? address,
    File? fileUserimg,
    String? fcmToken,
    String? notification,
    String? latitude,
    String? longitude,
    String? city,
    String? state,
    String? phone,
    String? country,
    String? countryCode,
    String? instagram,
    String? facebook,
    String? youtube,
    String? twitter,
  }) async {
    final parameters = <String, dynamic>{
      Api.name: name ?? '',
      Api.email: email ?? '',
      Api.address: address ?? '',
      Api.fcmId: fcmToken ?? '',
      // Api.userid: HiveUtils.getUserId(), //commented-user-id
      'mobile': phone,
      Api.notification: notification,
      'city': city ?? HiveUtils.getUserCityName(),
      'state': state ?? HiveUtils.getUserStateName(),
      'country': country ?? HiveUtils.getUserCountryName(),
      'country_code': countryCode ?? '',
      'facebook_id': facebook ?? '',
      'twiiter_id': twitter ?? '',
      'instagram_id': instagram ?? '',
      'youtube_id': youtube ?? '',
    };
    if (fileUserimg != null) {
      parameters['profile'] = await MultipartFile.fromFile(fileUserimg.path);
    }

    if (latitude != null && longitude != null && city != null && city != '') {
      parameters.addAll({'latitude': latitude, 'longitude': longitude});
    } else {
      parameters.addAll({
        'latitude': '',
        'longitude': '',
      });
    }

    final response = await Api.post(
      url: Api.apiUpdateProfile,
      parameter: parameters,
    );

    if (response[Api.error] == true) {
      throw ApiException(response[Api.message]);
    }
    await HiveUtils.setUserData(response['data'] as Map<String, dynamic>);
    checkIsAuthenticated();

    return response;
  }
}
