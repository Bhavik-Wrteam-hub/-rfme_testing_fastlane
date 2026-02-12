import 'package:ebroker/data/repositories/report_property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<int> reportedProperties = [];

abstract class PropertyReportState {}

class PropertyReportInitial extends PropertyReportState {}

class PropertyReportInProgress extends PropertyReportState {}

class PropertyReportInSuccess extends PropertyReportState {
  PropertyReportInSuccess(this.responseMessage);
  final String responseMessage;
}

class PropertyReportFailure extends PropertyReportState {
  PropertyReportFailure(this.error);
  final dynamic error;
}

class PropertyReportCubit extends Cubit<PropertyReportState> {
  PropertyReportCubit() : super(PropertyReportInitial());
  ReportPropertyRepository repository = ReportPropertyRepository();
  Future<void> report({
    required int propertyId,
    required int reasonId,
    String? message,
  }) async {
    try {
      emit(PropertyReportInProgress());
      final result = await repository.reportProperty(
        reasonId: reasonId,
        propertyId: propertyId,
        message: message,
      );
      if (result['error'] == true) {
        emit(PropertyReportFailure(result['message']?.toString() ?? ''));
      }

      reportedProperties.add(propertyId);
      emit(PropertyReportInSuccess(result['message'].toString()));
    } on Exception catch (e) {
      emit(PropertyReportFailure(e));
    }
  }
}
