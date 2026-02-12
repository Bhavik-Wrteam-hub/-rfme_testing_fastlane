/// Model for AI-generated description content
class AiGeneratedDescriptionModel {
  AiGeneratedDescriptionModel({
    required this.description,
    this.entityType,
    this.entityId,
    this.languageId,
  });

  factory AiGeneratedDescriptionModel.fromMap(Map<String, dynamic> map) {
    return AiGeneratedDescriptionModel(
      description:
          map['description']?.toString() ??
          map['desc']?.toString() ??
          map['generated_description']?.toString() ??
          map['content']?.toString() ??
          '',
      entityType: map['entity_type']?.toString(),
      entityId: map['entity_id']?.toString(),
      languageId: map['language_id'] as int?,
    );
  }

  factory AiGeneratedDescriptionModel.fromString(String description) {
    return AiGeneratedDescriptionModel(
      description: description,
    );
  }

  /// The generated description text
  final String description;

  /// The entity type (property or project)
  final String? entityType;

  /// The entity ID if editing
  final String? entityId;

  /// The language ID for the description
  final int? languageId;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (languageId != null) 'language_id': languageId,
    };
  }

  AiGeneratedDescriptionModel copyWith({
    String? description,
    String? entityType,
    String? entityId,
    int? languageId,
  }) {
    return AiGeneratedDescriptionModel(
      description: description ?? this.description,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      languageId: languageId ?? this.languageId,
    );
  }
}
