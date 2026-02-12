import 'package:ebroker/data/model/ai_generated_description_model.dart';
import 'package:ebroker/data/model/ai_generated_meta_model.dart';
import 'package:ebroker/data/repositories/ai_generation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Entity types supported for AI generation
enum EntityType {
  property,
  project
  ;

  String get value {
    switch (this) {
      case EntityType.property:
        return 'property';
      case EntityType.project:
        return 'project';
    }
  }
}

/// Content types that can be generated
enum AiContentType {
  description,
  meta,
}

/// Base state for AI content generation
abstract class GenerateAiContentState {}

/// Initial state
class GenerateAiContentInitial extends GenerateAiContentState {}

/// State when generating description
class GenerateDescriptionInProgress extends GenerateAiContentState {
  GenerateDescriptionInProgress({
    required this.entityType,
    this.languageId,
  });

  final EntityType entityType;
  final int? languageId;
}

/// State when description generation is successful
class GenerateDescriptionSuccess extends GenerateAiContentState {
  GenerateDescriptionSuccess({
    required this.description,
    required this.entityType,
    this.languageId,
  });

  final AiGeneratedDescriptionModel description;
  final EntityType entityType;
  final int? languageId;
}

/// State when description generation fails
class GenerateDescriptionFailure extends GenerateAiContentState {
  GenerateDescriptionFailure({
    required this.error,
    required this.entityType,
    this.languageId,
  });

  final String error;
  final EntityType entityType;
  final int? languageId;
}

/// State when generating meta content
class GenerateMetaInProgress extends GenerateAiContentState {
  GenerateMetaInProgress({
    required this.entityType,
  });

  final EntityType entityType;
}

/// State when meta generation is successful
class GenerateMetaSuccess extends GenerateAiContentState {
  GenerateMetaSuccess({
    required this.meta,
    required this.entityType,
  });

  final AiGeneratedMetaModel meta;
  final EntityType entityType;
}

/// State when meta generation fails
class GenerateMetaFailure extends GenerateAiContentState {
  GenerateMetaFailure({
    required this.error,
    required this.entityType,
  });

  final String error;
  final EntityType entityType;
}

/// Cubit for managing AI content generation (description and meta)
class GenerateAiContentCubit extends Cubit<GenerateAiContentState> {
  GenerateAiContentCubit() : super(GenerateAiContentInitial());

  final AiGenerationRepository _repository = AiGenerationRepository();

  /// Generate description for a property or project
  ///
  /// [entityType] - property or project
  /// [languageId] - language ID for the description
  /// [entityId] - optional entity ID when editing
  /// [context] - additional context like title, location, price, etc.
  Future<void> generateDescription({
    required EntityType entityType,
    required int languageId,
    String? entityId,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) async {
    emit(
      GenerateDescriptionInProgress(
        entityType: entityType,
        languageId: languageId,
      ),
    );

    try {
      final description = await _repository.generateDescription(
        entityType: entityType.value,
        languageId: languageId,
        entityId: entityId,
        context: context,
      );

      emit(
        GenerateDescriptionSuccess(
          description: description,
          entityType: entityType,
          languageId: languageId,
        ),
      );
    } on Exception catch (e) {
      emit(
        GenerateDescriptionFailure(
          error: e.toString(),
          entityType: entityType,
          languageId: languageId,
        ),
      );
    }
  }

  /// Generate meta content (title, description, keywords) for a property or project
  ///
  /// [entityType] - property or project
  /// [entityId] - optional entity ID when editing
  /// [context] - additional context like title, location, price, etc.
  /// [languageId] - optional language ID
  Future<void> generateMeta({
    required EntityType entityType,
    String? entityId,
    Map<String, dynamic> context = const <String, dynamic>{},
    int? languageId,
  }) async {
    emit(
      GenerateMetaInProgress(
        entityType: entityType,
      ),
    );

    try {
      final meta = await _repository.generateMeta(
        entityType: entityType.value,
        entityId: entityId,
        context: context,
        languageId: languageId,
      );

      emit(
        GenerateMetaSuccess(
          meta: meta,
          entityType: entityType,
        ),
      );
    } on Exception catch (e) {
      emit(
        GenerateMetaFailure(
          error: e.toString(),
          entityType: entityType,
        ),
      );
    }
  }

  /// Reset to initial state
  void reset() {
    emit(GenerateAiContentInitial());
  }
}
