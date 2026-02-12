import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChangePropertyStatusState {}

class ChangePropertyStatusInitial extends ChangePropertyStatusState {}

class ChangePropertyStatusInProgress extends ChangePropertyStatusState {}

class ChangePropertyStatusSuccess extends ChangePropertyStatusState {
  ChangePropertyStatusSuccess();

  ChangePropertyStatusSuccess copyWith() {
    return ChangePropertyStatusSuccess();
  }
}

class ChangePropertyStatusFailure extends ChangePropertyStatusState {
  ChangePropertyStatusFailure(this.error);
  final String error;
}

class ChangePropertyStatusCubit extends Cubit<ChangePropertyStatusState> {
  ChangePropertyStatusCubit() : super(ChangePropertyStatusInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> enableProperty({
    required int propertyId,
    required int status,
  }) async {
    try {
      emit(ChangePropertyStatusInProgress());
      final result = await _propertyRepository.changePropertyStatus(
        propertyId: propertyId,
        status: status,
      );
      if (result['error'] == true) {
        emit(ChangePropertyStatusFailure(result['message']?.toString() ?? ''));
      } else {
        emit(
          ChangePropertyStatusSuccess(),
        );
      }
    } on Exception catch (e) {
      emit(ChangePropertyStatusFailure(e.toString()));
    }
  }
}
