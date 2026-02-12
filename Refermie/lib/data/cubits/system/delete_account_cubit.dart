import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAccountState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountProgress extends DeleteAccountState {}

class DeleteAccountFailure extends DeleteAccountState {
  DeleteAccountFailure(this.errorMessage);
  final String errorMessage;
}

class AccountDeleted extends DeleteAccountState {
  AccountDeleted({required this.successMessage});
  final String successMessage;
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(DeleteAccountInitial());
  Future<void> deleteUserAccount(BuildContext context) async {
    emit(DeleteAccountProgress());
    await deleteAccount(context)
        .then((value) => emit(AccountDeleted(successMessage: value)))
        .catchError((dynamic e) => emit(DeleteAccountFailure(e.toString())));
  }

  Future<String> deleteAccount(BuildContext context) async {
    var message = '';

    /* User? currentUser = await FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
      }*/
    final parameter = <String, String>{
      // Api.userid: HiveUtils.getUserId()!,
    };

    final response = await Api.post(
      url: Api.apiDeleteUser,
      parameter: parameter,
    );

    if (response['error'] == true) {
      throw CustomException(response['message']);
    } else {
      Future.delayed(
        Duration.zero,
        () async {
          await HiveUtils.logoutUser(
            context,
            onLogout: () {},
            isRedirect: false,
          );
        },
      );
      message = response['message']?.toString() ?? '';
    }

    return message;
  }
}
