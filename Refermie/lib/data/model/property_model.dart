import 'dart:convert';

import 'package:ebroker/data/model/translation_model.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';
import 'package:flutter/foundation.dart';

class PropertyModel implements NativeAdWidgetContainer {
  PropertyModel({
    this.id,
    this.title,
    this.translatedTitle,
    this.translatedDescription,
    this.customerName,
    this.customerEmail,
    this.customerNumber,
    this.customerProfile,
    this.price,
    this.category,
    this.unitType,
    this.description,
    this.address,
    this.clientAddress,
    this.propertyType,
    this.titleImage,
    this.postCreated,
    this.gallery,
    this.totalView,
    this.status,
    this.requestStatus,
    this.state,
    this.city,
    this.country,
    this.addedBy,
    this.inquiry,
    this.promoted,
    this.isFavourite,
    this.rentduration,
    this.isInterested,
    this.favouriteUsers,
    this.interestedUsers,
    this.totalInterestedUsers,
    this.totalFavouriteUsers,
    this.parameters,
    this.latitude,
    this.longitude,
    this.threeDImage,
    this.advertisment,
    this.video,
    this.assignedOutdoorFacility,
    this.slugId,
    this.allPropData,
    this.lowQualityTitleImage,
    this.documents,
    this.isVerified,
    this.isFeatureAvailable,
    this.advertisementId,
    this.advertisementStatus,
    this.advertisementType,
    this.isBlockedByUser,
    this.isBlockedByMe,
    this.rejectReason,
    this.isPremium,
    this.translations,
    this.propertiesCount,
    this.projectsCount,
    this.isAppointmentAvailable,
    this.isAppointmentBooked,
    this.isAdmin,
    this.editReason,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> rawjson) {
    return PropertyModel(
      id: rawjson['id'] as int,
      allPropData: rawjson,
      slugId: rawjson['slug_id']?.toString(),
      rentduration: rawjson['rentduration']?.toString(),
      customerEmail: rawjson['email']?.toString(),
      customerProfile: rawjson['profile']?.toString(),
      customerNumber: rawjson['mobile']?.toString(),
      customerName: rawjson['customer_name']?.toString(),
      video: rawjson['video_link']?.toString(),
      threeDImage: rawjson['three_d_image']?.toString(),
      latitude: rawjson['latitude']?.toString(),
      longitude: rawjson['longitude']?.toString(),
      title: rawjson['title']?.toString(),
      translatedTitle: rawjson['translated_title']?.toString(),
      price: rawjson['price']?.toString(),
      category: rawjson['category'] == null
          ? null
          : Categorys.fromMap(
              rawjson['category'] as Map<String, dynamic>? ?? {},
            ),
      advertisment: rawjson['advertisement'],
      unitType: rawjson['unit_type'] == null
          ? null
          : UnitType.fromMap(
              rawjson['unit_type'] as Map<String, dynamic>? ?? {},
            ),
      description: rawjson['description']?.toString(),
      translatedDescription: rawjson['translated_description']?.toString(),
      address: rawjson['address']?.toString(),
      clientAddress: rawjson['client_address']?.toString(),
      propertyType: rawjson['property_type']?.toString() ?? '',
      titleImage: rawjson['title_image']?.toString(),
      postCreated: rawjson['post_created']?.toString(),
      gallery: List<Gallery>.from(
        (rawjson['gallery'] as List? ?? []).map(
          (x) => Gallery.fromMap(
            (x is String ? json.decode(x) : x) as Map<String, dynamic>? ?? {},
          ),
        ),
      ),
      documents: List<PropertyDocuments>.from(
        (rawjson['documents'] as List? ?? []).map(
          (x) => PropertyDocuments.fromMap(
            (x is String ? json.decode(x) : x) as Map<String, dynamic>? ?? {},
          ),
        ),
      ),
      totalView: rawjson['total_view']?.toString() ?? '0',
      status: rawjson['status']?.toString() ?? '0',
      requestStatus: rawjson['request_status']?.toString(),
      state: rawjson['state']?.toString(),
      city: rawjson['city']?.toString(),
      country: rawjson['country']?.toString(),
      addedBy: rawjson['added_by']?.toString(),
      inquiry: rawjson['inquiry'] as bool? ?? false,
      promoted: rawjson['promoted'] as bool? ?? false,
      isFavourite: rawjson['is_favourite']?.toString(),
      isInterested: rawjson['is_interested']?.toString(),
      favouriteUsers:
          (rawjson['favourite_users'] as List<dynamic>?)
              ?.map((x) => x)
              .toList() ??
          [],
      interestedUsers:
          (rawjson['interested_users'] as List<dynamic>?)
              ?.map((x) => x)
              .toList() ??
          [],
      totalInterestedUsers:
          rawjson['total_interested_users']?.toString() ?? '0',
      totalFavouriteUsers: rawjson['total_favourite_users']?.toString(),
      parameters: rawjson['parameters'] == null
          ? []
          : List<Parameter>.from(
              (rawjson['parameters'] as List? ?? []).map((x) {
                return Parameter.fromMap(x as Map<String, dynamic>? ?? {});
              }),
            ),
      assignedOutdoorFacility: rawjson['assign_facilities'] == null
          ? []
          : List<AssignedOutdoorFacility>.from(
              (rawjson['assign_facilities'] as List? ?? []).map((x) {
                return AssignedOutdoorFacility.fromJson(
                  x as Map<String, dynamic>? ?? {},
                );
              }),
            ),
      lowQualityTitleImage: rawjson['low_quality_title_image']?.toString(),
      isVerified: rawjson['is_verified'] as bool? ?? false,
      isFeatureAvailable: rawjson['is_feature_available'] as bool? ?? false,
      advertisementId: rawjson['advertisement_id']?.toString() ?? '',
      advertisementStatus: rawjson['advertisement_status']?.toString() ?? '',
      advertisementType: rawjson['advertisement_type']?.toString(),
      isBlockedByUser: rawjson['is_blocked_by_user'] as bool? ?? false,
      isBlockedByMe: rawjson['is_blocked_by_me'] as bool? ?? false,
      rejectReason: rawjson['reject_reason'] == null
          ? null
          : RejectReason.fromMap(
              rawjson['reject_reason'] as Map<String, dynamic>? ?? {},
            ),
      isPremium: rawjson['is_premium'] as bool? ?? false,
      translations: (rawjson['translations'] as List? ?? [])
          .map((e) => Translations.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      propertiesCount: rawjson['customer_total_properties']?.toString() ?? '',
      projectsCount: rawjson['customer_total_projects']?.toString() ?? '',
      isAppointmentAvailable:
          rawjson['is_appointment_available'] as bool? ?? false,
      isAppointmentBooked: rawjson['is_appointment_booked'] as bool? ?? false,
      isAdmin: rawjson['is_admin'] as bool? ?? false,
      editReason: rawjson['edit_reason']?.toString(),
    );
  }

  final int? id;
  final String? title;
  final String? translatedTitle;
  final String? translatedDescription;
  final String? price;
  final String? customerName;
  final String? customerEmail;
  final String? customerProfile;
  final String? customerNumber;
  final String? rentduration;
  final Categorys? category;
  final UnitType? unitType;
  final String? description;
  final String? address;
  final String? clientAddress;
  String? propertyType;
  final String? titleImage;
  final String? lowQualityTitleImage;
  final String? postCreated;
  final List<Gallery>? gallery;
  final List<PropertyDocuments>? documents;
  final String? totalView;
  final String? status;
  final String? requestStatus;
  final String? state;
  final String? city;
  final String? country;
  final String? addedBy;
  final bool? inquiry;
  final bool? promoted;
  final String? isFavourite;
  final String? isInterested;
  final List<dynamic>? favouriteUsers;
  final List<dynamic>? interestedUsers;
  final String? totalInterestedUsers;
  final String? totalFavouriteUsers;
  final List<Parameter>? parameters;
  final List<AssignedOutdoorFacility>? assignedOutdoorFacility;
  final String? latitude;
  final String? longitude;
  final String? threeDImage;
  final String? video;
  final dynamic advertisment;
  final String? slugId;
  final dynamic allPropData;
  final bool? isVerified;
  final bool? isFeatureAvailable;
  final String? advertisementId;
  final String? advertisementStatus;
  final String? advertisementType;
  final bool? isBlockedByUser;
  final bool? isBlockedByMe;
  final RejectReason? rejectReason;
  final bool? isPremium;
  final List<Translations>? translations;
  final String? propertiesCount;
  final String? projectsCount;
  final bool? isAppointmentAvailable;
  final bool? isAppointmentBooked;
  final bool? isAdmin;
  final String? editReason;
  PropertyModel copyWith({
    int? id,
    String? title,
    String? translatedTitle,
    String? translatedDescription,
    String? price,
    Categorys? category,
    UnitType? unitType,
    String? description,
    String? address,
    String? clientAddress,
    String? propertyType,
    String? titleImage,
    String? postCreated,
    List<Gallery>? gallery,
    String? totalView,
    String? status,
    String? requestStatus,
    String? state,
    String? city,
    String? country,
    String? addedBy,
    bool? inquiry,
    bool? promoted,
    String? isFavourite,
    String? isInterested,
    List<dynamic>? favouriteUsers,
    List<dynamic>? interestedUsers,
    String? totalInterestedUsers,
    String? totalFavouriteUsers,
    List<Parameter>? parameters,
    List<AssignedOutdoorFacility>? assignedOutdoorFacility,
    String? latitude,
    String? longitude,
    String? threeDImage,
    String? video,
    String? rentduration,
    String? lowQualityTitleImage,
    List<PropertyDocuments>? documents,
    bool? isVerified,
    bool? isFeatureAvailable,
    String? advertisementId,
    String? advertisementStatus,
    String? advertisementType,
    bool? isBlockedByUser,
    bool? isBlockedByMe,
    RejectReason? rejectReason,
    dynamic advertisment,
    bool? isPremium,
    List<Translations>? translations,
    String? propertiesCount,
    String? projectsCount,
    bool? isAppointmentAvailable,
    bool? isAppointmentBooked,
    bool? isAdmin,
    String? editReason,
  }) => PropertyModel(
    id: id ?? this.id,
    rentduration: rentduration ?? this.rentduration,
    advertisment: advertisment ?? this.advertisment,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    title: title ?? this.title,
    translatedTitle: translatedTitle ?? this.translatedTitle,
    translatedDescription: translatedDescription ?? this.translatedDescription,
    price: price ?? this.price,
    category: category ?? this.category,
    unitType: unitType ?? this.unitType,
    description: description ?? this.description,
    address: address ?? this.address,
    clientAddress: clientAddress ?? this.clientAddress,
    propertyType: propertyType ?? this.propertyType,
    titleImage: titleImage ?? this.titleImage,
    postCreated: postCreated ?? this.postCreated,
    gallery: gallery ?? this.gallery,
    totalView: totalView ?? this.totalView,
    status: status ?? this.status,
    requestStatus: requestStatus ?? this.requestStatus,
    state: state ?? this.state,
    city: city ?? this.city,
    country: country ?? this.country,
    addedBy: addedBy ?? this.addedBy,
    inquiry: inquiry ?? this.inquiry,
    promoted: promoted ?? this.promoted,
    isFavourite: isFavourite ?? this.isFavourite,
    isInterested: isInterested ?? this.isInterested,
    favouriteUsers: favouriteUsers ?? this.favouriteUsers,
    interestedUsers: interestedUsers ?? this.interestedUsers,
    totalInterestedUsers: totalInterestedUsers ?? this.totalInterestedUsers,
    totalFavouriteUsers: totalFavouriteUsers ?? this.totalFavouriteUsers,
    parameters: parameters ?? this.parameters,
    threeDImage: threeDImage ?? threeDImage,
    video: video ?? this.video,
    assignedOutdoorFacility:
        assignedOutdoorFacility ?? this.assignedOutdoorFacility,
    lowQualityTitleImage: lowQualityTitleImage ?? this.lowQualityTitleImage,
    documents: documents ?? this.documents,
    isVerified: isVerified ?? this.isVerified,
    isFeatureAvailable: isFeatureAvailable ?? this.isFeatureAvailable,
    advertisementId: advertisementId ?? this.advertisementId,
    advertisementStatus: advertisementStatus ?? this.advertisementStatus,
    advertisementType: advertisementType ?? this.advertisementType,
    isBlockedByUser: isBlockedByUser ?? this.isBlockedByUser,
    isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
    rejectReason: rejectReason ?? this.rejectReason,
    isPremium: isPremium ?? this.isPremium,
    translations: translations ?? this.translations,
    propertiesCount: propertiesCount ?? this.propertiesCount,
    projectsCount: projectsCount ?? this.projectsCount,
    isAppointmentAvailable:
        isAppointmentAvailable ?? this.isAppointmentAvailable,
    isAppointmentBooked: isAppointmentBooked ?? this.isAppointmentBooked,
    isAdmin: isAdmin ?? this.isAdmin,
    editReason: editReason ?? this.editReason,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'allPropData': allPropData,
    'rentduration': rentduration,
    'mobile': customerNumber,
    'email': customerEmail,
    'customer_name': customerName,
    'profile': customerProfile,
    'three_d_image': threeDImage,
    'title': title,
    'slug_id': slugId,
    'translated_title': translatedTitle,
    'translated_description': translatedDescription,
    'latitude': latitude,
    'longitude': longitude,
    'advertisment': advertisment,
    'video_link': video,
    'price': price,
    'category': category?.toMap() ?? {},
    'unit_type': unitType?.toMap() ?? {},
    'description': description,
    'address': address,
    'client_address': clientAddress,
    'property_type': propertyType,
    'title_image': titleImage,
    'post_created': postCreated,
    'gallery': List<Gallery>.from(gallery?.map((x) => x) ?? []),
    'documents': List<PropertyDocuments>.from(documents?.map((x) => x) ?? []),
    'total_view': totalView,
    'status': status,
    'request_status': requestStatus,
    'state': state,
    'city': city,
    'country': country,
    'added_by': addedBy,
    'inquiry': inquiry,
    'promoted': promoted,
    'is_favourite': isFavourite,
    'is_interested': isInterested,
    'favourite_users': favouriteUsers == null
        ? null
        : List<dynamic>.from(favouriteUsers?.map((x) => x) ?? []),
    'interested_users': interestedUsers == null
        ? null
        : List<dynamic>.from(interestedUsers?.map((x) => x) ?? []),
    'total_interested_users': totalInterestedUsers,
    'total_favourite_users': totalFavouriteUsers,
    'assign_facilities': assignedOutdoorFacility == null
        ? null
        : List<dynamic>.from(
            assignedOutdoorFacility?.map((e) => e.toJson()) ?? [],
          ),
    'parameters': parameters == null
        ? null
        : List<dynamic>.from(parameters?.map((x) => x.toMap()) ?? []),
    'low_quality_title_image': lowQualityTitleImage,
    'is_verified': isVerified,
    'is_feature_available': isFeatureAvailable,
    'advertisement_id': advertisementId,
    'advertisement_status': advertisementStatus,
    'advertisement_type': advertisementType,
    'is_blocked_by_user': isBlockedByUser,
    'is_blocked_by_me': isBlockedByMe,
    'reject_reason': rejectReason,
    'is_premium': isPremium,
    'translations': translations,
    'customer_total_properties': propertiesCount,
    'customer_total_projects': projectsCount,
    'is_appointment_available': isAppointmentAvailable,
    'is_appointment_booked': isAppointmentBooked,
    'is_admin': isAdmin,
    'edit_reason': editReason,
  };

  @override
  String toString() {
    return '''PropertyModel(id: $id,rentduration:$rentduration , title: $title,assigned_facilities:[$assignedOutdoorFacility]  advertisment:$advertisment, price: $price, category: $category, unitType: $unitType, description: $description, translatedDiscription: $translatedDescription  address: $address, clientAddress: $clientAddress, propertyType: $propertyType, titleImage: $titleImage, low_quality_title_image: $lowQualityTitleImage, postCreated: $postCreated, gallery: $gallery, documents: $documents, totalView: $totalView, status: $status,requestStatus: $requestStatus, state: $state, city: $city, country: $country, addedBy: $addedBy, inquiry: $inquiry, promoted: $promoted, isFavourite: $isFavourite, isInterested: $isInterested, favouriteUsers: $favouriteUsers, interestedUsers: $interestedUsers, totalInterestedUsers: $totalInterestedUsers, totalFavouriteUsers: $totalFavouriteUsers, parameters: $parameters, latitude: $latitude, longitude: $longitude, threeDImage: $threeDImage, video: $video, isVerified: $isVerified, rejectReason: $rejectReason, translations: $translations, isAppointmentAvailable: $isAppointmentAvailable, isAppointmentBooked: $isAppointmentBooked, isAdmin: $isAdmin, editReason: $editReason)''';
  }
}

class RejectReason {
  RejectReason({
    this.id,
    this.propertyId,
    this.projectId,
    this.reason,
  });

  factory RejectReason.fromJson(String str) =>
      RejectReason.fromMap(json.decode(str) as Map<String, dynamic>? ?? {});

  factory RejectReason.fromMap(Map<String, dynamic> json) => RejectReason(
    id: json['id'] as int?,
    propertyId: json['property_id']?.toString(),
    projectId: json['project_id']?.toString(),
    reason: json['reason']?.toString(),
  );

  final int? id;
  final String? propertyId;
  final String? projectId;
  final String? reason;

  RejectReason copyWith({
    int? id,
    String? propertyId,
    String? projectId,
    String? reason,
  }) => RejectReason(
    id: id ?? this.id,
    propertyId: propertyId ?? this.propertyId,
    projectId: projectId ?? this.projectId,
    reason: reason ?? this.reason,
  );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    'id': id,
    'property_id': propertyId,
    'project_id': projectId,
    'reason': reason,
  };
}

class Categorys {
  Categorys({
    this.id,
    this.category,
    this.image,
    this.translatedName,
  });

  factory Categorys.fromJson(String str) =>
      Categorys.fromMap(json.decode(str) as Map<String, dynamic>? ?? {});

  factory Categorys.fromMap(Map<String, dynamic> json) => Categorys(
    id: json['id'] as int?,
    category: json['category']?.toString(),
    image: json['image']?.toString(),
    translatedName: json['translated_name']?.toString(),
  );

  final int? id;
  final String? category;
  final String? image;
  final String? translatedName;

  Categorys copyWith({
    int? id,
    String? category,
    String? image,
    String? translatedName,
  }) => Categorys(
    id: id ?? this.id,
    category: category ?? this.category,
    image: image ?? this.image,
    translatedName: translatedName ?? this.translatedName,
  );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'image': image,
    'translated_name': translatedName,
  };
}

class Parameter {
  Parameter({
    this.id,
    this.name,
    this.typeOfParameter,
    this.typeValues,
    this.image,
    this.value,
    this.isRequired,
    this.translatedName,
    this.translatedOptionValue,
    this.translatedValue,
  });

  factory Parameter.fromMap(Map<String, dynamic> json) {
    return Parameter(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      typeOfParameter: json['type_of_parameter']?.toString(),
      typeValues: json['type_values'],
      image: json['image']?.toString(),
      value: ifListConvertToString(json['value']),
      isRequired: json['is_required']?.toString() ?? '0',
      translatedName: json['translated_name']?.toString(),
      translatedOptionValue:
          json['translated_option_value'] as List<dynamic>? ?? [],
      translatedValue: json['translated_value'] as List<dynamic>? ?? [],
    );
  }

  final int? id;
  final String? name;
  final String? typeOfParameter;
  final dynamic typeValues;
  final String? image;
  final dynamic value;
  final String? isRequired;
  final String? translatedName;
  final List<dynamic>? translatedOptionValue;
  final List<dynamic>? translatedValue;

  Parameter copyWith({
    int? id,
    String? name,
    String? typeOfParameter,
    dynamic typeValues,
    String? image,
    dynamic value,
    String? isRequired,
    String? translatedName,
    List<dynamic>? translatedOptionValue,
    List<dynamic>? translatedValue,
  }) => Parameter(
    id: id ?? this.id,
    name: name ?? this.name,
    typeOfParameter: typeOfParameter ?? this.typeOfParameter,
    typeValues: typeValues ?? this.typeValues,
    image: image ?? this.image,
    value: value ?? this.value,
    isRequired: isRequired ?? this.isRequired,
    translatedName: translatedName ?? this.translatedName,
    translatedOptionValue: translatedOptionValue ?? this.translatedOptionValue,
    translatedValue: translatedValue ?? this.translatedValue,
  );

  static dynamic ifListConvertToString(dynamic value) {
    if (value is List) {
      return value.join(',');
    }

    return value;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type_of_parameter': typeOfParameter,
    'type_values': typeValues,
    'image': image,
    'value': value,
    'is_required': isRequired,
    'translated_name': translatedName,
    'translated_option_value': translatedOptionValue,
    'translated_value': translatedValue,
  };

  @override
  String toString() {
    return '''Parameter(id: $id, name: $name, typeOfParameter: $typeOfParameter, typeValues: $typeValues, image: $image, value: $value, isRequired: $isRequired ,translatedName: $translatedName, translatedOptionValue: $translatedOptionValue, translatedValue: $translatedValue)''';
  }
}

class UnitType {
  UnitType({
    this.id,
    this.measurement,
  });

  factory UnitType.fromJson(String str) =>
      UnitType.fromMap(json.decode(str) as Map<String, dynamic>? ?? {});

  factory UnitType.fromMap(Map<String, dynamic> json) => UnitType(
    id: json['id'] as int?,
    measurement: json['measurement']?.toString(),
  );

  final int? id;
  final String? measurement;

  UnitType copyWith({
    int? id,
    String? measurement,
  }) => UnitType(
    id: id ?? this.id,
    measurement: measurement ?? this.measurement,
  );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    'id': id,
    'measurement': measurement,
  };
}

@immutable
class Gallery {
  const Gallery({
    required this.id,
    required this.image,
    required this.imageUrl,
    this.isVideo,
  });

  factory Gallery.fromMap(Map<String, dynamic> map) {
    return Gallery(
      id: map['id'] as int,
      image: map['image']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
    );
  }

  factory Gallery.fromJson(String source) =>
      Gallery.fromMap(json.decode(source) as Map<String, dynamic>? ?? {});
  final int id;
  final String image;
  final String imageUrl;
  final bool? isVideo;

  Gallery copyWith({
    int? id,
    String? image,
    String? imageUrl,
  }) {
    return Gallery(
      id: id ?? this.id,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'image_url': imageUrl,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'Gallery(id: $id, image: $image, imageUrl: $imageUrl)';

  @override
  bool operator ==(covariant Gallery other) {
    if (identical(this, other)) return true;

    return other.id == id && other.image == image && other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id.hashCode ^ image.hashCode ^ imageUrl.hashCode;
}

class AssignedOutdoorFacility {
  AssignedOutdoorFacility({
    this.id,
    this.propertyId,
    this.facilityId,
    this.distance,
    this.createdAt,
    this.name,
    this.translatedName,
    this.image,
    this.updatedAt,
  });

  AssignedOutdoorFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    propertyId = json['property_id']?.toString();
    facilityId = json['facility_id']?.toString();
    distance = json['distance'].toString();
    createdAt = json['created_at']?.toString();
    image = json['image']?.toString();
    name = json['name']?.toString();
    translatedName = json['translated_name']?.toString();
    updatedAt = json['updated_at']?.toString();
  }
  int? id;
  String? propertyId;
  String? facilityId;
  String? distance;
  String? image;
  String? name;
  String? translatedName;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['property_id'] = propertyId;
    data['facility_id'] = facilityId;
    data['distance'] = distance.toString();
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image'] = image;
    data['name'] = name;
    data['translated_name'] = translatedName;
    return data;
  }

  @override
  String toString() {
    return '''AssignedOutdoorFacility{id: $id, propertyId: $propertyId, facilityId: $facilityId, distance: $distance, image: $image, name: $name, translatedName: $translatedName, createdAt: $createdAt, updatedAt: $updatedAt}''';
  }
}

class PropertyDocuments {
  PropertyDocuments({
    required this.name,
    this.id,
    this.type,
    this.file,
    this.propertyId,
  });

  factory PropertyDocuments.fromMap(Map<String, dynamic> json) {
    return PropertyDocuments(
      id: json['id'] as int?,
      name: json['file_name']?.toString() ?? '',
      type: json['type']?.toString(),
      file: json['file']?.toString(),
      propertyId: json['property_id']?.toString(),
    );
  }

  factory PropertyDocuments.fromJson(String source) =>
      PropertyDocuments.fromMap(
        json.decode(source) as Map<String, dynamic>? ?? {},
      );

  int? id;
  String name;
  String? type;
  String? file;
  String? propertyId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': name,
      'type': type,
      'file': file,
      'property_id': propertyId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return '''PropertyDocuments(id: $id, name: $name, type: $type, file: $file, propertyId: $propertyId)''';
  }
}
