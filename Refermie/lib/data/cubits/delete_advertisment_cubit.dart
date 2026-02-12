import 'package:ebroker/data/repositories/advertisement_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAdvertismentState {}

class DeleteAdvertismentInitial extends DeleteAdvertismentState {}

class DeleteAdvertismentInProgress extends DeleteAdvertismentState {}

class DeleteAdvertismentSuccess extends DeleteAdvertismentState {}

class DeleteAdvertismentFailure extends DeleteAdvertismentState {
  DeleteAdvertismentFailure(this.errorMessage);
  final String errorMessage;
}

class DeleteAdvertismentCubit extends Cubit<DeleteAdvertismentState> {
  DeleteAdvertismentCubit(this._advertisementRepository)
      : super(DeleteAdvertismentInitial());
  final AdvertisementRepository _advertisementRepository;

  Future<void> delete(
    String id,
  ) async {
    try {
      emit(DeleteAdvertismentInProgress());
      await _advertisementRepository.deleteAdvertisment(id);
      emit(DeleteAdvertismentSuccess());
    } on ApiException catch (e) {
      emit(DeleteAdvertismentFailure(e.toString()));
    }
  }
}
