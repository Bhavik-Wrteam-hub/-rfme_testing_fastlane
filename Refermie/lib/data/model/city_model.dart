import 'dart:convert';

class City {
  City({
    required this.name,
    required this.count,
    required this.image,
  });

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      name: map['City']?.toString() ?? '',
      count: map['Count']?.toString() ?? '0',
      image: map['image']?.toString() ?? '',
    );
  }

  factory City.fromJson(String source) =>
      City.fromMap(json.decode(source) as Map<String, dynamic>);
  final String name;
  final String count;
  final String image;

  @override
  String toString() => 'City(name: $name, count: $count, image: $image)';

  City copyWith({String? name, String? count, String? image}) {
    return City(
      name: name ?? this.name,
      count: count ?? this.count,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'City': name, 'Count': count, 'image': image};
  }

  String toJson() => json.encode(toMap());
}
