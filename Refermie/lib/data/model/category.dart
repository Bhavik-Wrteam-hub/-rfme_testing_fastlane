import 'dart:convert';

import 'package:ebroker/utils/api.dart';

class Category {
  Category(
      {this.id,
      this.category,
      this.image,
      this.parameterTypes,
      this.translatedName});

  Category.fromJson(Map<String, dynamic> json) {
    id = json[Api.id] as int?;
    category = json[Api.category]?.toString() ?? '';
    image = json[Api.image]?.toString() ?? '';
    parameterTypes = json[Api.parameterTypes] is Map
        ? json[Api.parameterTypes]['parameters'] as List? ?? []
        : ((json[Api.parameterTypes] as List?) ?? []);
    translatedName = json['translated_name'] as String? ?? '';
  }

  Category.fromProperty(Map<String, dynamic> json) {
    id = json[Api.id] as int?;
    category = json[Api.category]?.toString() ?? '';
    translatedName = json['translated_name'] as String? ?? '';
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      category: map['category'] != null ? map['category'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      parameterTypes: map['parameterTypes'] as List? ?? [],
      translatedName: map['translated_name'] as String? ?? '',
    );
  }
  int? id;
  String? category;
  String? image;
  List<dynamic>? parameterTypes;
  String? translatedName;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'image': image,
      'parameterTypes': parameterTypes,
      'translated_name': translatedName,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return '''Category(id: $id, category: $category, image: $image, parameterTypes: $parameterTypes, translatedName: $translatedName)''';
  }
}

class Type {
  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type]?.toString() ?? '';
  }
  String? id;
  String? type;
}
