import 'package:ebroker/data/repositories/auth_repository.dart';

import 'package:ebroker/exports/main_export.dart';

String verificationID = '';

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpInProgress extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  SendOtpSuccess({
    this.verificationId,
    this.message,
  });
  String? verificationId;
  String? message;
}

class SendOtpFailure extends SendOtpState {
  SendOtpFailure(this.errorMessage);
  final String errorMessage;
}

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit() : super(SendOtpInitial());

  final AuthRepository _authRepository = AuthRepository();
  Future<void> sendFirebaseOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    emit(SendOtpInProgress());
    await _authRepository.sendOTP(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      onCodeSent: (verificationId) {
        verificationID = verificationId;
        emit(SendOtpSuccess(verificationId: verificationId));
      },
      onError: (e) {
        emit(SendOtpFailure(e.toString()));
      },
    );
  }

  Future<void> sendTwilioOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    emit(SendOtpInProgress());

    await _authRepository.sendOTP(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      onCodeSent: (verificationId) {
        verificationID = verificationId;
        emit(SendOtpSuccess(verificationId: verificationId));
      },
      onError: (e) {
        emit(SendOtpFailure(e.toString()));
      },
    );
  }

  Future<void> sendForgotPasswordEmail({
    required String email,
  }) async {
    emit(SendOtpInProgress());
    try {
      final result = await _authRepository.sendForgotPasswordEmail(
        email: email,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']?.toString() ?? ''));
      } else {
        emit(SendOtpSuccess(message: result['message']?.toString() ?? ''));
      }
    } on ApiException catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> sendEmailOTP({
    required String email,
    required String name,
    required String phoneNumber,
    required String countryCode,
    required String password,
    required String confirmPassword,
  }) async {
    emit(SendOtpInProgress());
    try {
      final result = await _authRepository.sendEmailOTP(
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']?.toString() ?? ''));
      } else {
        emit(SendOtpSuccess());
      }
    } on ApiException catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> resendEmailOTP({
    required String email,
    required String password,
  }) async {
    try {
      emit(SendOtpInProgress());
      final result = await _authRepository.resendEmailOTP(
        email: email,
        password: password,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']?.toString() ?? ''));
      } else {
        emit(SendOtpSuccess());
      }
    } on ApiException catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> sendPhoneRegistrationOTP({
    required String phoneNumber,
    required String countryCode,
    required String name,
    required String password,
    required String confirmPassword,
    String? email,
  }) async {
    emit(SendOtpInProgress());
    try {
      // First, register the user data in backend
      final result = await _authRepository.sendPhoneRegistrationOTP(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        name: name,
        password: password,
        confirmPassword: confirmPassword,
        email: email,
      );

      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']?.toString() ?? ''));
        return;
      }

      // After successful registration data storage, send OTP via Firebase/Twilio
      if (AppSettings.otpServiceProvider == 'firebase') {
        await _authRepository.sendOTP(
          phoneNumber: phoneNumber,
          countryCode: countryCode,
          onCodeSent: (verificationId) {
            verificationID = verificationId;
            emit(SendOtpSuccess(verificationId: verificationId));
          },
          onError: (e) {
            emit(SendOtpFailure(e.toString()));
          },
        );
      } else if (AppSettings.otpServiceProvider == 'twilio') {
        await _authRepository.sendOTP(
          phoneNumber: phoneNumber,
          countryCode: countryCode,
          onCodeSent: (verificationId) {
            verificationID = verificationId;
            emit(SendOtpSuccess(verificationId: verificationId));
          },
          onError: (e) {
            emit(SendOtpFailure(e.toString()));
          },
        );
      }
    } on ApiException catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }
}
