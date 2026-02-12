import 'package:ebroker/data/model/appointment/booking_preferences_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchBookingPreferencesState {}

class FetchBookingPreferencesInitial extends FetchBookingPreferencesState {}

class FetchBookingPreferencesLoading extends FetchBookingPreferencesState {}

class FetchBookingPreferencesSuccess extends FetchBookingPreferencesState {
  FetchBookingPreferencesSuccess(this.bookingPreferences);
  final BookingPreferencesModel bookingPreferences;
}

class FetchBookingPreferencesFailure extends FetchBookingPreferencesState {
  FetchBookingPreferencesFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchBookingPreferencesCubit extends Cubit<FetchBookingPreferencesState> {
  FetchBookingPreferencesCubit() : super(FetchBookingPreferencesInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchBookingPreferences() async {
    try {
      emit(FetchBookingPreferencesLoading());
      final bookingPreferences = await _appointmentRepository
          .getBookingPreferences();
      emit(FetchBookingPreferencesSuccess(bookingPreferences));
    } on ApiException catch (e) {
      emit(FetchBookingPreferencesFailure(e.toString()));
    }
  }

  void clear() {
    emit(FetchBookingPreferencesInitial());
  }
}
