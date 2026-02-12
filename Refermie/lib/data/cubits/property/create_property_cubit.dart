import 'dart:developer';

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreatePropertyState {}

class CreatePropertyInitial extends CreatePropertyState {}

class CreatePropertyInProgress extends CreatePropertyState {}

class CreatePropertySuccess extends CreatePropertyState {
  CreatePropertySuccess({
    this.propertyModel,
  });
  final PropertyModel? propertyModel;
}

class CreatePropertyFailure extends CreatePropertyState {
  CreatePropertyFailure(this.errorMessage);
  final String errorMessage;
}

class CreatePropertyCubit extends Cubit<CreatePropertyState> {
  CreatePropertyCubit() : super(CreatePropertyInitial());
  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> create({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(CreatePropertyInProgress());
      final result = await _propertyRepository.createProperty(
            parameters: parameters,
          ) as Map<String, dynamic>? ??
          {};
      final data = result['data'][0] as Map<String, dynamic>?;
      if (result['error'] == true) {
        emit(CreatePropertyFailure(result['message']?.toString() ?? ''));
        return;
      }

      if (result['data'] != null) {
        emit(
          CreatePropertySuccess(
            propertyModel: PropertyModel.fromMap(data ?? {}),
          ),
        );
      } else {
        emit(CreatePropertyFailure(result['message'].toString()));
      }
    } on Exception catch (e, st) {
      log(e.toString());
      log(st.toString());
      emit(CreatePropertyFailure(e.toString()));
    }
  }
}
