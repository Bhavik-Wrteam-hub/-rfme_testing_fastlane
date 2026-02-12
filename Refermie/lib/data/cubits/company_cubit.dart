import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/data/model/company.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyFetchProgress extends CompanyState {}

class CompanyFetchSuccess extends CompanyState {
  CompanyFetchSuccess(this.companyData);
  Company companyData;
}

class CompanyFetchFailure extends CompanyState {
  CompanyFetchFailure(this.error);
  final dynamic error;
}

class CompanyCubit extends Cubit<CompanyState> {
  CompanyCubit() : super(CompanyInitial());

  Future<void> fetchCompany() async {
    emit(CompanyFetchProgress());
    await fetchCompanyFromDb()
        .then((value) => emit(CompanyFetchSuccess(value)))
        .catchError((Object e) => emit(CompanyFetchFailure(e)));
  }

  Future<Company> fetchCompanyFromDb() async {
    try {
      final body = <String, String>{
        Api.type: Api.company,
      };

      final response = await Api.get(
        url: Api.apiGetAppSettings,
        queryParameters: body,
      );

      if (response[Api.error] as bool) {
        throw CustomException(response[Api.message]);
      }

      return Company.fromJson(response['data'] as Map<String, dynamic>);
    } on Exception catch (_) {
      rethrow;
    }
  }
}
