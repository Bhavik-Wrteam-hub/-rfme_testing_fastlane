import 'package:dio/dio.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/exports/main_export.dart';

class ProjectRepository {
  Future<Map<String, dynamic>?> createProject(
    Map<dynamic, dynamic> projectPayload,
  ) async {
    try {
      final multipartData = _multipartImages(projectPayload);
      final images = projectPayload['gallery_images'];
      multipartData.remove('gallery_images');
      var galleryImages = <String, dynamic>{};
      if (images != null) {
        galleryImages = (images as MultiValue).value.fold({}, (
          previousValue,
          element,
        ) {
          if (element.value is! String) {
            previousValue.addAll({
              'gallery_images[${previousValue.length}]':
                  MultipartFile.fromFileSync((element.value as File).path),
            });
          }

          return previousValue;
        });
      }

      multipartData.addAll(galleryImages);
      final map = await Api.post(
        url: Api.postProject,
        parameter: multipartData,
      );
      return map;
    } on Exception catch (_) {
      return null;
      // throw e;
    }
  }

  Future<DataOutput<ProjectModel>> fetchAllProjects({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getProjects,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<ProjectModel>> fetchPromotedProjects({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getProjects,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
        'get_featured': 1,
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<ProjectModel>> getMyProjects({
    required int offset,
  }) async {
    final result = await Api.get(
      url: Api.getAddedProjects,
      queryParameters: {'offset': offset},
    );
    final list = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(result['total']?.toString() ?? '0'),
      modelList: list,
    );
  }

  Future<DataOutput<ProjectModel>> getProjects({
    int? offset,
  }) async {
    final result = await Api.get(
      url: Api.getProjects,
      queryParameters: {'offset': offset},
    );
    final list = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(result['total']?.toString() ?? '0'),
      modelList: list,
    );
  }

  Future<ProjectModel> getProjectDetails(
    BuildContext context, {
    required int id,
    required bool isMyProject,
  }) async {
    final result = await Api.get(
      url: isMyProject ? Api.getAddedProjects : Api.getProjectDetails,
      queryParameters: {'id': id},
    );
    if (result['error'] == true) {
      throw ApiException(result['message'].toString().translate(context));
    }
    return ProjectModel.fromMap(result['data'] as Map<String, dynamic>? ?? {});
  }

  Future<ProjectModel> fetchBySlug(String slug) async {
    final result = await Api.get(
      url: Api.getProjects,
      queryParameters: {'slug_id': slug},
    );

    // Ensure 'data' is a List and safely extract the first item
    final data = result['data'];
    if (data is List && data.isNotEmpty) {
      final firstItem = data.first;
      if (firstItem is Map<String, dynamic>) {
        return ProjectModel.fromMap(firstItem);
      }
    }

    // Handle cases where data is null or in an unexpected format
    throw Exception('Invalid data format received');
  }

  Map<String, dynamic> _multipartImages(Map<dynamic, dynamic> data) {
    return data.map((key, value) {
      if (value is FileValue) {
        return MapEntry(
          key?.toString() ?? '',
          MultipartFile.fromFileSync(value.value.path),
        );
      }
      if (value is MultiValue && key != 'gallery_images') {
        final images = value.value.map((image) {
          if (image is FileValue) {
            return MultipartFile.fromFileSync(image.value.path);
          }
        }).toList();
        return MapEntry(key?.toString() ?? '', images);
      }
      if (value is List<File>) {
        final files = value
            .map((e) => MultipartFile.fromFileSync(e.path))
            .toList();
        return MapEntry(key?.toString() ?? '', files);
      }
      if (value is Map) {
        final v = _multipartImages(value);
        return MapEntry(key?.toString() ?? '', v);
      }
      if (value is List) {
        final list = value.map((e) {
          if (e is Map) {
            return _multipartImages(e);
          }
          return <String, dynamic>{};
        }).toList();
        return MapEntry(key?.toString() ?? '', list);
      }

      return MapEntry(key?.toString() ?? '', value);
    });
  }

  Future<DataOutput<ProjectModel>> fetchProjectFromProjectId(dynamic id) async {
    final parameters = <String, dynamic>{
      Api.id: id,
    };

    final response = await Api.get(
      url: Api.getProjects,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<Map<String, dynamic>> changeProjectStatus({
    required int projectId,
    required int status,
  }) async {
    final parameters = <String, dynamic>{
      'project_id': projectId,
      Api.status: status,
    };
    final response = await Api.post(
      url: Api.changeProjectStatus,
      parameter: parameters,
    );
    return response;
  }

  Future<DataOutput<AdvertisementProject>> fetchMyPromotedProjects() async {
    final parameters = <String, dynamic>{
      Api.type: 'project',
    };

    final response = await Api.get(
      url: Api.getFeaturedData,
      queryParameters: parameters,
    );
    if (response['error'] == true) {
      throw ApiException(response['message'].toString());
    }
    if (response['data'] == null) {
      return DataOutput(
        total: 0,
        modelList: [],
      );
    }

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<AdvertisementProject>(AdvertisementProject.fromJson)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }
}
