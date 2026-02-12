import 'dart:developer';

import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/model/home_section_data_model.dart';
import 'package:ebroker/data/model/other_sections_model.dart';
import 'package:ebroker/data/model/project_sections_model.dart';
import 'package:ebroker/data/model/property_sections_model.dart';
import 'package:ebroker/exports/main_export.dart';

class HomeScreenDataRepository {
  Map<String, dynamic> _locationParameters() {
    final latitude = HiveUtils.getLatitude()?.toString() ?? '';
    final longitude = HiveUtils.getLongitude()?.toString() ?? '';
    final radius = HiveUtils.getRadius()?.toString() ?? '';
    return <String, dynamic>{
      'latitude': latitude.isNotEmpty ? latitude : null,
      'longitude': longitude.isNotEmpty ? longitude : null,
      'radius': radius.isNotEmpty ? radius : AppSettings.minRadius,
    }..removeWhere((key, value) => value == '' || value == null);
  }

  Future<HomeSectionDataModel> fetchSectionsData() async {
    try {
      final result = await Api.get(
        url: Api.homepageSectionsData,
      );
      return HomeSectionDataModel.fromApiResponse(result);
    } on Exception catch (e, st) {
      log(
        e.toString(),
        stackTrace: st,
        name: 'HOME SECTIONS DATA ERROR:',
      );
      rethrow;
    }
  }

  Future<PropertySectionsModel> fetchPropertySections() async {
    try {
      final result = await Api.get(
        url: Api.homepagePropertySections,
        queryParameters: _locationParameters(),
      );
      return PropertySectionsModel.fromApiResponse(result);
    } on Exception catch (e, st) {
      log(
        e.toString(),
        stackTrace: st,
        name: 'HOME PROPERTY SECTIONS ERROR:',
      );
      rethrow;
    }
  }

  Future<ProjectSectionsModel> fetchProjectSections() async {
    try {
      final result = await Api.get(
        url: Api.homepageProjectSections,
        queryParameters: _locationParameters(),
      );
      return ProjectSectionsModel.fromApiResponse(result);
    } on Exception catch (e, st) {
      log(
        e.toString(),
        stackTrace: st,
        name: 'HOME PROJECT SECTIONS ERROR:',
      );
      rethrow;
    }
  }

  Future<OtherSectionsModel> fetchOtherSections() async {
    try {
      final result = await Api.get(
        url: Api.homepageOtherSections,
        queryParameters: _locationParameters(),
      );
      return OtherSectionsModel.fromApiResponse(result);
    } on Exception catch (e, st) {
      log(
        e.toString(),
        stackTrace: st,
        name: 'HOME OTHER SECTIONS ERROR:',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchPropertiesByCities() async {
    try {
      final result = await Api.get(
        url: Api.apiGetPropertiesByCity,
      );

      final dynamic dataNode = result['data'];
      List<dynamic> rawList;
      if (dataNode is Map<String, dynamic> && dataNode['data'] is List) {
        rawList = dataNode['data'] as List<dynamic>;
      } else if (dataNode is List) {
        rawList = dataNode;
      } else if (result['cities'] is List) {
        rawList = result['cities'] as List<dynamic>;
      } else {
        rawList = const [];
      }
      final isWithImage = dataNode['with_image'] as bool? ?? false;

      return {
        'cities': rawList
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => City.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        'isWithImage': isWithImage,
      };
    } on Exception catch (e, st) {
      log(
        e.toString(),
        stackTrace: st,
        name: 'PROPERTIES BY CITIES ERROR:',
      );
      rethrow;
    }
  }
}
