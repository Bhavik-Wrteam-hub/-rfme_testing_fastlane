import 'dart:convert';

class LanguagesModel {
  LanguagesModel({
    this.id,
    this.code,
    this.name,
  });

  LanguagesModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    code = json['code']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
  }

  factory LanguagesModel.fromMap(Map<String, dynamic> map) {
    return LanguagesModel(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
  String? id;
  String? code;
  String? name;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return '''LanguagesModel(id: $id, code: $code, name: $name)''';
  }
}
