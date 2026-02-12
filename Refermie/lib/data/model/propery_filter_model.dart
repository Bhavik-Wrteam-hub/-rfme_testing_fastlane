import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class PropertyFilterModel {
  const PropertyFilterModel({
    required this.propertyType,
    required this.maxPrice,
    required this.minPrice,
    required this.categoryId,
    required this.postedSince,
    required this.city,
    required this.state,
    required this.country,
    required this.facilities,
  });

  factory PropertyFilterModel.createEmpty() {
    return const PropertyFilterModel(
      propertyType: '',
      maxPrice: '',
      minPrice: '',
      categoryId: '',
      postedSince: '',
      city: '',
      country: '',
      state: '',
      facilities: [],
    );
  }
  factory PropertyFilterModel.fromMap(Map<String, dynamic> map) {
    return PropertyFilterModel(
      city: map['city'].toString(),
      state: map['state'].toString(),
      country: map['country'].toString(),
      propertyType: map['property_type'].toString(),
      maxPrice: map['max_price'].toString(),
      minPrice: map['min_price'].toString(),
      categoryId: map['category_id'].toString(),
      postedSince: map['posted_since'].toString(),
      facilities: (map['facilities'] as List? ?? []).cast<int>(),
    );
  }

  factory PropertyFilterModel.fromJson(String source) =>
      PropertyFilterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final String propertyType;
  final String maxPrice;
  final String minPrice;
  final String categoryId;
  final String postedSince;
  final String city;
  final String state;
  final String country;
  final List<int> facilities;

  PropertyFilterModel copyWith({
    String? propertyType,
    String? maxPrice,
    String? minPrice,
    String? categoryId,
    String? postedSince,
    String? city,
    String? state,
    String? country,
  }) {
    return PropertyFilterModel(
      propertyType: propertyType ?? this.propertyType,
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      categoryId: categoryId ?? this.categoryId,
      postedSince: postedSince ?? this.postedSince,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      facilities: facilities,
    );
  }

  Map<String, dynamic> toMap() {
    final priceMap = <String, dynamic>{};
    if (minPrice.isNotEmpty) priceMap['min_price'] = minPrice;
    if (maxPrice.isNotEmpty) priceMap['max_price'] = maxPrice;

    return <String, dynamic>{
      'property_type': propertyType,
      if (priceMap.isNotEmpty) 'price': priceMap,
      'category_id': categoryId,
      'posted_since': postedSince,
      'city': city,
      'state': state,
      'country': country,
      'facilities': facilities,
    };
  }

  @override
  String toString() {
    return '''PropertyFilterModel(propertyType: $propertyType, maxPrice: $maxPrice, minPrice: $minPrice, categoryId: $categoryId, postedSince: $postedSince, facilities: $facilities)''';
  }

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(covariant PropertyFilterModel other) {
    if (identical(this, other)) return true;

    return other.propertyType == propertyType &&
        other.maxPrice == maxPrice &&
        other.minPrice == minPrice &&
        other.categoryId == categoryId &&
        other.postedSince == postedSince;
  }

  @override
  int get hashCode {
    return propertyType.hashCode ^
        maxPrice.hashCode ^
        minPrice.hashCode ^
        categoryId.hashCode ^
        postedSince.hashCode;
  }
}
