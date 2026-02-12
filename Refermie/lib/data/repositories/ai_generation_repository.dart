import 'package:ebroker/data/model/ai_generated_description_model.dart';
import 'package:ebroker/data/model/ai_generated_meta_model.dart';
import 'package:ebroker/utils/api.dart';

/// Repository for AI content generation
class AiGenerationRepository {
  /// Generate description content for a property or project
  ///
  /// [entityType] should be 'property' or 'project'
  /// [languageId] is the language ID for the description
  /// [entityId] is optional, used when editing existing entity
  /// [context] contains additional context like title, location, etc.
  Future<AiGeneratedDescriptionModel> generateDescription({
    required String entityType,
    required int languageId,
    String? entityId,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) async {
    try {
      final description = await Api.generateDescriptionContent(
        entityType: entityType,
        entityId: entityId,
        languageId: languageId,
        context: context,
      );

      return AiGeneratedDescriptionModel.fromString(description);
    } on Exception catch (e) {
      throw ApiException('$e');
    }
  }

  /// Generate meta content (title, description, keywords) for a property or project
  ///
  /// [entityType] should be 'property' or 'project'
  /// [entityId] is optional, used when editing existing entity
  /// [context] contains additional context like title, location, etc.
  /// [languageId] is optional language ID
  Future<AiGeneratedMetaModel> generateMeta({
    required String entityType,
    String? entityId,
    Map<String, dynamic> context = const <String, dynamic>{},
    int? languageId,
  }) async {
    try {
      final metaMap = await Api.generateMetaContent(
        entityType: entityType,
        entityId: entityId,
        context: context,
        languageId: languageId,
      );

      return AiGeneratedMetaModel.fromMap(metaMap);
    } on Exception catch (e) {
      throw ApiException('$e');
    }
  }
}
