class OutdoorFacility {
  OutdoorFacility({
    this.id,
    this.translatedName,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.distance,
  });

  OutdoorFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    translatedName = json['translated_name']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    image = json['image']?.toString() ?? '';
    createdAt = json['created_at']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
    distance = json['distance']?.toString() ?? '';
  }
  int? id;
  String? translatedName;
  String? name;
  String? image;
  String? distance;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['translated_name'] = translatedName;
    data['name'] = name;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['distance'] = distance.toString();
    return data;
  }

  @override
  String toString() {
    return '''OutdoorFacility{id: $id, translatedName: $translatedName, name: $name, image: $image, createdAt: $createdAt, updatedAt: $updatedAt, distance: $distance}''';
  }
}
