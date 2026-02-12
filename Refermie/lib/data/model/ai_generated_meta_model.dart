/// Model for AI-generated meta details (title, description, keywords)
class AiGeneratedMetaModel {
  AiGeneratedMetaModel({
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
    this.entityType,
    this.entityId,
  });

  factory AiGeneratedMetaModel.fromMap(Map<String, dynamic> map) {
    return AiGeneratedMetaModel(
      metaTitle:
          map['meta_title']?.toString() ?? map['title']?.toString() ?? '',
      metaDescription:
          map['meta_description']?.toString() ??
          map['description']?.toString() ??
          '',
      metaKeywords:
          map['meta_keywords']?.toString() ?? map['keywords']?.toString() ?? '',
      entityType: map['entity_type']?.toString(),
      entityId: map['entity_id']?.toString(),
    );
  }

  /// The generated meta title
  final String metaTitle;

  /// The generated meta description
  final String metaDescription;

  /// The generated meta keywords
  final String metaKeywords;

  /// The entity type (property or project)
  final String? entityType;

  /// The entity ID if editing
  final String? entityId;

  Map<String, dynamic> toMap() {
    return {
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
    };
  }

  AiGeneratedMetaModel copyWith({
    String? metaTitle,
    String? metaDescription,
    String? metaKeywords,
    String? entityType,
    String? entityId,
  }) {
    return AiGeneratedMetaModel(
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      metaKeywords: metaKeywords ?? this.metaKeywords,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
    );
  }
}
