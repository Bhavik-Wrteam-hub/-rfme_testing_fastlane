import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProgress extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  VerifyOtpSuccess({
    this.authId,
    this.number,
    this.otp,
    this.credential,
  });
  final dynamic credential;
  final String? authId;
  final String? number;
  final String? otp;
}

class VerifyOtpFailure extends VerifyOtpState {
  VerifyOtpFailure(this.errorMessage);
  final String errorMessage;
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpCubit() : super(VerifyOtpInitial());
  final AuthRepository _authRepository = AuthRepository();

  Future<void> verifyOTP({
    required String otp,
    String? verificationId,
    String? number,
    String? countryCode,
  }) async {
    try {
      if (AppSettings.otpServiceProvider == 'firebase') {
        emit(VerifyOtpInProgress());
        final userCredential = await _authRepository.verifyFirebaseOTP(
          otpVerificationId: verificationId!,
          otp: otp,
        );
        emit(VerifyOtpSuccess(credential: userCredential));
      } else if (AppSettings.otpServiceProvider == 'twilio') {
        emit(VerifyOtpInProgress());
        final credential = await _authRepository.verifyTwilioOTP(
          countryCode: countryCode!,
          number: number!,
          otp: otp,
        ) as Map<dynamic, dynamic>;
        final authId = credential['auth_id']?.toString() ?? '';
        emit(
          VerifyOtpSuccess(authId: authId, number: number),
        );
      }
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(ErrorFilter.check(e.code).error?.toString() ?? ''));
    } on ApiException catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }

  Future<void> verifyEmailOTP({
    required String otp,
    required String email,
  }) async {
    try {
      emit(VerifyOtpInProgress());
      final credential = await _authRepository.verifyEmailOTP(
        otp: otp,
        email: email,
      ) as Map<dynamic, dynamic>;
      if (credential['error'] == true) {
        emit(VerifyOtpFailure(credential['message']?.toString() ?? ''));
        return;
      }
      emit(VerifyOtpSuccess(credential: credential['data']));
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(ErrorFilter.check(e.code).error?.toString() ?? ''));
    } on ApiException catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }
}
