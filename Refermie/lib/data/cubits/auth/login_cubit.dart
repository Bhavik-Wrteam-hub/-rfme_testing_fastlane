import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  LoginSuccess({
    required this.isProfileCompleted,
  });
  final bool isProfileCompleted;
}

class LoginFailure extends LoginState {
  LoginFailure(this.errorMessage, this.key);
  final String errorMessage;
  final String key;
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthRepository _authRepository = AuthRepository();
  bool isProfileIsCompleted = true;

  Future<void> login({
    required String phoneNumber,
    required String uniqueId,
    required LoginType type,
    required String countryCode,
    String? email,
    String? name,
    String? password,
    String? reEnteredPassword,
  }) async {
    try {
      emit(LoginInProgress());
      final result = await _authRepository.loginWithApi(
        type: type,
        email: email,
        name: name,
        phone: phoneNumber,
        uid: uniqueId,
        countryCode: countryCode,
      );

      if (result['error'] == true) {
        isProfileIsCompleted = false;
        emit(
          LoginFailure(
            result['message']?.toString() ?? '',
            result['key']?.toString() ?? '',
          ),
        );
        return;
      }

      ///Storing data to local database {HIVE}
      await HiveUtils.setJWT(result['token']?.toString() ?? '');

      isProfileIsCompleted = true;
      final data = result['data'] as Map;
      data['country_code'] = countryCode;
      data['type'] = type.name;

      await HiveUtils.setUserData(data);

      emit(LoginSuccess(isProfileCompleted: isProfileIsCompleted));
    } on ApiException catch (e) {
      emit(LoginFailure(e.toString(), e.toString()));
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
    required LoginType type,
  }) async {
    try {
      emit(LoginInProgress());
      final result = await _authRepository.loginWithEmail(
        email: email,
        password: password,
        type: type,
      );

      if (result['error'] == true) {
        isProfileIsCompleted = false;
        emit(
          LoginFailure(
            result['message']?.toString() ?? '',
            result['key']?.toString() ?? '',
          ),
        );
        return;
      }
      if (result['error'] != true) {
        ///Storing data to local database {HIVE}
        await HiveUtils.setJWT(result['token']?.toString() ?? '');

        isProfileIsCompleted = true;
        final data = result['data'] as Map;
        data['type'] = type.name;

        await HiveUtils.setUserData(data);
      }

      emit(LoginSuccess(isProfileCompleted: isProfileIsCompleted));
    } on ApiException catch (e) {
      emit(LoginFailure(e.toString(), e.toString()));
    }
  }

  Future<void> loginWithPhone({
    required String phone,
    required String password,
    required String countryCode,
    required LoginType type,
  }) async {
    try {
      emit(LoginInProgress());
      final result = await _authRepository.loginWithPhone(
        phone: phone,
        password: password,
        countryCode: countryCode,
        type: type,
      );

      if (result['error'] == true) {
        isProfileIsCompleted = false;
        emit(
          LoginFailure(
            result['message']?.toString() ?? '',
            result['key']?.toString() ?? '',
          ),
        );
        return;
      }
      if (result['error'] != true) {
        ///Storing data to local database {HIVE}
        await HiveUtils.setJWT(result['token']?.toString() ?? '');

        isProfileIsCompleted = true;
        final data = result['data'] as Map;
        data['country_code'] = countryCode;
        data['type'] = type.name;

        await HiveUtils.setUserData(data);
      }

      emit(LoginSuccess(isProfileCompleted: isProfileIsCompleted));
    } on ApiException catch (e) {
      emit(LoginFailure(e.toString(), e.toString()));
    }
  }
}
