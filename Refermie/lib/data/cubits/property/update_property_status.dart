import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdatePropertyStatusState {}

class UpdatePropertyStatusInitial extends UpdatePropertyStatusState {}

class UpdatePropertyStatusInProgress extends UpdatePropertyStatusState {}

class UpdatePropertyStatusSuccess extends UpdatePropertyStatusState {}

class UpdatePropertyStatusFail extends UpdatePropertyStatusState {
  UpdatePropertyStatusFail({
    required this.error,
  });
  final dynamic error;
}

class UpdatePropertyStatusCubit extends Cubit<UpdatePropertyStatusState> {
  UpdatePropertyStatusCubit() : super(UpdatePropertyStatusInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> update({
    required dynamic propertyId,
    required dynamic status,
  }) async {
    try {
      emit(UpdatePropertyStatusInProgress());
      await _propertyRepository.updatePropertyStatus(
        propertyId: propertyId,
        status: status,
      );
      emit(UpdatePropertyStatusSuccess());
    } on Exception catch (e) {
      emit(UpdatePropertyStatusFail(error: e.toString()));
    }
  }
}
