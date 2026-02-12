import 'dart:convert';

import 'package:ebroker/exports/main_export.dart';

class HomeSlider {
  HomeSlider({
    this.id,
    this.image,
    this.categoryId,
    this.propertysId,
    this.promoted,
    this.sliderType,
    this.link,
    this.property,
    this.category,
    this.showPropertyDetails,
  });

  HomeSlider.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    categoryId = json[Api.categoryId].toString();
    image = json[Api.image]?.toString() ?? '';
    propertysId = json[Api.propertysId].toString();
    promoted = json[Api.promoted] as bool? ?? false;
    sliderType = json['slider_type']?.toString() ?? '';
    link = json['link']?.toString() ?? '';
    showPropertyDetails = json['show_property_details'] == '1';
    property = json['property'] != null
        ? PropertyModel.fromMap(json['property'] as Map<String, dynamic>? ?? {})
        : null;
    category = json['category'] != null
        ? Categorys.fromMap(json['category'] as Map<String, dynamic>? ?? {})
        : null;
  }

  factory HomeSlider.fromMap(Map<String, dynamic> map) {
    return HomeSlider(
      id: map['id'] != null ? map['id'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      categoryId: map['categoryId'] != null
          ? map['categoryId'] as String
          : null,
      propertysId: map['propertysId'] != null
          ? map['propertysId'] as String
          : null,
      promoted: map['promoted'] != null ? map['promoted'] as bool : null,
      sliderType: map['sliderType'] != null
          ? map['sliderType'] as String
          : null,
      link: map['link'] != null ? map['link'] as String : null,
      showPropertyDetails: map['show_property_details'] == '1',
      property: map['property'] != null
          ? PropertyModel.fromMap(
              map['property'] as Map<String, dynamic>? ?? {},
            )
          : null,
      category: map['category'] != null
          ? Categorys.fromMap(map['category'] as Map<String, dynamic>? ?? {})
          : null,
    );
  }
  String? id;
  String? image;
  String? categoryId;
  String? propertysId;
  bool? promoted;
  String? sliderType;
  String? link;
  PropertyModel? property;
  Categorys? category;
  bool? showPropertyDetails;
  @override
  String toString() {
    return '''HomeSlider(id: $id, image: $image, categoryId: $categoryId, propertysId: $propertysId, promoted: $promoted, sliderType: $sliderType, link: $link, property: $property, category: $category, showPropertyDetails: $showPropertyDetails)''';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'categoryId': categoryId,
      'propertysId': propertysId,
      'promoted': promoted,
      'sliderType': sliderType,
      'link': link,
      'property': property?.toMap(),
      'category': category?.toMap(),
      'showPropertyDetails': showPropertyDetails,
    };
  }

  String toJson() => json.encode(toMap());
}
