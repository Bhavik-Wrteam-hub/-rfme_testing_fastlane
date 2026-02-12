import 'package:ebroker/data/model/facilities_model.dart';
import 'package:ebroker/data/model/outdoor_facility.dart';
import 'package:ebroker/data/repositories/facilities_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class FetchFacilitiesState {}

class FetchFacilitiesInitial extends FetchFacilitiesState {}

class FetchFacilitiesLoading extends FetchFacilitiesState {}

class FetchFacilitiesSuccess extends FetchFacilitiesState {
  FetchFacilitiesSuccess(
      {required this.facilities, required this.outdoorFacilities});
  final List<FacilitiesModel> facilities;
  final List<OutdoorFacility> outdoorFacilities;
}

class FetchFacilitiesCubit extends Cubit<FetchFacilitiesState> {
  FetchFacilitiesCubit() : super(FetchFacilitiesInitial());
  final FacilitiesRepository _facilitiesRepository = FacilitiesRepository();

  Future<void> fetch() async {
    emit(FetchFacilitiesLoading());
    final allFacilities = await _facilitiesRepository.fetchFacilities();
    emit(
      FetchFacilitiesSuccess(
        facilities: (allFacilities['parameters'] as List)
            .cast<Map<String, dynamic>>()
            .map<FacilitiesModel>(FacilitiesModel.fromJson)
            .toList(),
        outdoorFacilities: (allFacilities['nearby_facilities'] as List)
            .cast<Map<String, dynamic>>()
            .map<OutdoorFacility>(OutdoorFacility.fromJson)
            .toList(),
      ),
    );
  }
}
