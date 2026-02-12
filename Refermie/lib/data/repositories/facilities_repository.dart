import 'package:ebroker/exports/main_export.dart';

class FacilitiesRepository {
  Future<Map<String, dynamic>> fetchFacilities() async {
    final response = await Api.get(
      url: Api.getAdvanceFilter,
    );
    return response['data'] as Map<String, dynamic>;
  }
}
