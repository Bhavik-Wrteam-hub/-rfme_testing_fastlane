class FacilitiesModel {
  const FacilitiesModel({
    this.id,
    this.name,
    this.translatedName,
    this.typeOfParameter,
    this.typeValues,
    this.translatedValues,
    this.image,
    this.isRequired,
  });

  FacilitiesModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name']?.toString() ?? '',
        translatedName = json['translated_name']?.toString() ?? '',
        typeOfParameter = json['type_of_parameter']?.toString() ?? '',
        typeValues = (json['type_values'] as List?)
                ?.where((element) => element != null)
                .map((element) => element.toString())
                .toList() ??
            [],
        translatedValues = (json['translated_option_value'] as List? ?? [])
            .where((element) => element != null)
            .map((element) => TranslatedValues.fromJson(
                element as Map<String, dynamic>? ?? {}))
            .toList(),
        image = json['image']?.toString() ?? '',
        isRequired = json['is_required']?.toString() ?? '0';
  final int? id;
  final String? name;
  final String? translatedName;
  final String? typeOfParameter;
  final List<String>? typeValues;
  final List<TranslatedValues>? translatedValues;
  final String? image;
  final String? isRequired;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'translated_name': translatedName,
        'type_of_parameter': typeOfParameter,
        'type_values': typeValues,
        'translated_option_value': translatedValues,
        'image': image,
        'is_required': isRequired,
      };
}

class TranslatedValues {
  const TranslatedValues({
    this.value,
    this.translated,
  });

  TranslatedValues.fromJson(Map<String, dynamic> json)
      : value = json['value']?.toString() ?? '',
        translated = json['translated']?.toString() ?? '';

  final String? value;
  final String? translated;

  Map<String, dynamic> toJson() => {
        'value': value,
        'translated': translated,
      };
}
