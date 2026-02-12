import 'package:ebroker/data/model/home_page_data_model.dart';

/// Parses `/api/homepage/sections-data` response.
///
/// Backend shape may vary slightly across deployments; this model is tolerant:
/// - Accepts `sections` or `data` as the list node.
class HomeSectionDataModel {
  HomeSectionDataModel({required this.sections});

  factory HomeSectionDataModel.fromApiResponse(Map<String, dynamic> json) {
    final dynamic dataNode = json['data'];
    // Some backends might return `sections` at root; some nest it under `data`.
    final dynamic sectionsNode =
        (dataNode is Map<String, dynamic>
            ? (dataNode['sections'] ?? dataNode)
            : null) ??
        json['sections'] ??
        json['data'];

    final rawList = (sectionsNode is List)
        ? sectionsNode
        : (sectionsNode is Map<String, dynamic> &&
              sectionsNode['sections'] is List)
        ? sectionsNode['sections'] as List
        : const <dynamic>[];

    final sections = rawList
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => HomePageSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return HomeSectionDataModel(sections: sections);
  }

  final List<HomePageSection> sections;
}
