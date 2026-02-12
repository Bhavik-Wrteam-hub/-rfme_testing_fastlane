import 'package:ebroker/data/repositories/advertisement_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateAdvertisementState {}

class CreateAdvertisementInitial extends CreateAdvertisementState {}

class CreateAdvertisementInProgress extends CreateAdvertisementState {}

class CreateAdvertisementSuccess extends CreateAdvertisementState {
  CreateAdvertisementSuccess({
    required this.message,
  });
  final String message;
}

class CreateAdvertisementFailure extends CreateAdvertisementState {
  CreateAdvertisementFailure(
    this.errorMessage,
  );
  final String errorMessage;
}

class CreateAdvertisementCubit extends Cubit<CreateAdvertisementState> {
  CreateAdvertisementCubit()
      : super(
          CreateAdvertisementInitial(),
        );
  final AdvertisementRepository _advertisementRepository =
      AdvertisementRepository();

  Future<void> create({
    required String featureFor,
    String? propertyId,
    String? projectId,
  }) async {
    try {
      emit(CreateAdvertisementInProgress());
      final result = await _advertisementRepository.create(
        featureFor: featureFor,
        projectId: projectId ?? '',
        propertyId: propertyId ?? '',
      );

      emit(
        CreateAdvertisementSuccess(message: result),
      );
    } on Exception catch (e) {
      emit(CreateAdvertisementFailure(e.toString()));
    }
  }
}
