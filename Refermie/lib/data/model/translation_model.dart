class Translations {
  Translations(
      {this.id,
      this.languageId,
      this.key,
      this.value,
      this.translatableType,
      this.translatableId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    languageId = json['language_id']?.toString() ?? '';
    key = json['key']?.toString() ?? '';
    value = json['value']?.toString() ?? '';
    translatableType = json['translatable_type']?.toString() ?? '';
    translatableId = json['translatable_id']?.toString() ?? '';
    createdAt = json['created_at']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
    deletedAt = json['deleted_at']?.toString() ?? '';
  }
  String? id;
  String? languageId;
  String? key;
  String? value;
  String? translatableType;
  String? translatableId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['language_id'] = languageId;
    data['key'] = key;
    data['value'] = value;
    data['translatable_type'] = translatableType;
    data['translatable_id'] = translatableId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}
