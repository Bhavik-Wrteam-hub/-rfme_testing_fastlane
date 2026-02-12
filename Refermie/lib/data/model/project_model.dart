import 'dart:convert';

import 'package:ebroker/data/model/translation_model.dart';

class ProjectModel {
  ProjectModel({
    this.id,
    this.slugId,
    this.categoryId,
    this.title,
    this.description,
    this.translatedTitle,
    this.translatedDescription,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.metaImage,
    this.image,
    this.lowQualityImage,
    this.videoLink,
    this.location,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.addedBy,
    this.customer,
    this.gallaryImages,
    this.documents,
    this.plans,
    this.category,
    this.requestStatus,
    this.isPromoted,
    this.isFeatureAvailable,
    this.rejectReason,
    this.translations,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as int?,
      slugId: map['slug_id']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      translatedTitle: map['translated_title']?.toString() ?? '',
      translatedDescription: map['translated_description']?.toString() ?? '',
      metaTitle: map['meta_title']?.toString() ?? '',
      metaDescription: map['meta_description']?.toString() ?? '',
      metaKeywords: map['meta_keywords']?.toString() ?? '',
      metaImage: map['meta_image']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      lowQualityImage: map['low_quality_image']?.toString(),
      videoLink: map['video_link']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      latitude: map['latitude']?.toString() ?? '',
      longitude: map['longitude']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      status: map['status']?.toString() ?? '0',
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
      addedBy: map['added_by']?.toString() ?? '',
      customer: Customer.fromMap(
        map['customer'] as Map<String, dynamic>? ?? {},
      ),
      gallaryImages: (map['gallary_images'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<ProjectGalleryModel>(ProjectGalleryModel.fromMap)
          .toList(),
      documents: (map['documents'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<Document>(Document.fromMap)
          .toList(),
      plans: (map['plans'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<Plan>(Plan.fromMap)
          .toList(),
      category: ProjectCategory.fromMap(
        map['category'] as Map<String, dynamic>? ?? {},
      ),
      requestStatus: map['request_status'] as String? ?? '',
      isPromoted: map['is_promoted'] as bool? ?? false,
      isFeatureAvailable: map['is_feature_available'] as bool? ?? false,
      rejectReason: map['reject_reason'] == null
          ? null
          : RejectReason.fromMap(
              map['reject_reason'] as Map<String, dynamic>,
            ),
      translations: List<Translations>.from(
        (map['translations'] as List? ?? []).map((x) {
          return Translations.fromJson(x as Map<String, dynamic>? ?? {});
        }),
      ),
    );
  }
  int? id;
  String? slugId;
  String? categoryId;
  String? title;
  String? description;
  String? translatedTitle;
  String? translatedDescription;
  String? metaTitle;
  String? metaDescription;
  String? metaKeywords;
  String? metaImage;
  String? image;
  String? lowQualityImage;
  String? videoLink;
  String? location;
  String? latitude;
  String? longitude;
  String? city;
  String? state;
  String? country;
  String? type;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? addedBy;
  Customer? customer;
  List<ProjectGalleryModel>? gallaryImages;
  List<Document>? documents;
  List<Plan>? plans;
  ProjectCategory? category;
  String? requestStatus;
  bool? isFeatureAvailable;
  bool? isPromoted;
  RejectReason? rejectReason;
  final List<Translations>? translations;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug_id': slugId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'translated_title': translatedTitle,
      'translated_description': translatedDescription,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'meta_image': metaImage,
      'image': image,
      'low_quality_image': lowQualityImage,
      'video_link': videoLink,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'type': type,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'added_by': addedBy,
      'customer': customer?.toMap(),
      'gallary_images': gallaryImages?.map((e) => e.toMap()).toList(),
      'documents': documents?.map((x) => x.toMap()).toList(),
      'plans': plans?.map((x) => x.toMap()).toList(),
      'category': category?.toMap(),
      'request_status': requestStatus,
      'is_feature_available': isFeatureAvailable,
      'is_promoted': isPromoted,
      'reject_reason': rejectReason,
      'translations': translations,
    };
  }

  @override
  String toString() {
    return '''ProjectModel(id: $id, slugId: $slugId, categoryId: $categoryId, title: $title, description: $description, translatedTitle: $translatedTitle, translatedDescription: $translatedDescription metaTitle: $metaTitle, metaDescription: $metaDescription, metaKeywords: $metaKeywords, metaImage: $metaImage, image: $image, videoLink: $videoLink, location: $location, latitude: $latitude, longitude: $longitude, city: $city, state: $state, country: $country, type: $type, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, addedBy: $addedBy, customer: $customer, gallaryImages: $gallaryImages, documents: $documents, plans: $plans, category: $category, requestStatus: $requestStatus), isPromoted: $isPromoted, isFeatureAvailable: $isFeatureAvailable )''';
  }
}

class Customer {
  Customer({
    this.id,
    this.name,
    this.profile,
    this.email,
    this.mobile,
    this.isVerified,
    this.propertiesCount,
    this.projectsCount,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      profile: map['profile']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      mobile: map['mobile']?.toString() ?? '',
      isVerified: map['is_user_verified'] as bool? ?? false,
      propertiesCount: map['total_properties']?.toString() ?? '',
      projectsCount: map['total_projects']?.toString() ?? '',
    );
  }
  int? id;
  String? name;
  String? profile;
  String? email;
  String? mobile;
  bool? isVerified;
  String? propertiesCount;
  String? projectsCount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profile': profile,
      'email': email,
      'mobile': mobile,
      'is_user_verified': isVerified,
      'total_properties': propertiesCount,
      'property_count': propertiesCount,
      'projects_count': projectsCount,
      'total_projects': projectsCount,
    };
  }
}

class Document {
  Document({
    this.id,
    this.name,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.projectId,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
      projectId: map['project_id']?.toString() ?? '',
    );
  }
  int? id;
  String? name;
  String? type;
  String? createdAt;
  String? updatedAt;
  String? projectId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'project_id': projectId,
    };
  }
}

class Plan {
  Plan({
    this.id,
    this.title,
    this.document,
    this.createdAt,
    this.updatedAt,
    this.projectId,
  });

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'] as int?,
      title: map['title']?.toString() ?? '',
      document: map['document']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
      projectId: map['project_id']?.toString() ?? '',
    );
  }
  int? id;
  String? title;
  String? document;
  String? createdAt;
  String? updatedAt;
  String? projectId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'document': document,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'project_id': projectId,
    };
  }
}

class ProjectCategory {
  ProjectCategory({
    this.id,
    this.category,
    this.image,
    this.translatedName,
  });

  factory ProjectCategory.fromMap(Map<String, dynamic> map) {
    return ProjectCategory(
      id: map['id'] as int?,
      category: map['category']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      translatedName: map['translated_name']?.toString() ?? '',
    );
  }
  final int? id;
  final String? category;
  final String? image;
  final String? translatedName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'image': image,
      'translated_name': translatedName,
    };
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
      RejectReason.fromMap(json.decode(str) as Map<String, dynamic>);

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

class ProjectGalleryModel {
  const ProjectGalleryModel({
    required this.id,
    required this.imageUrl,
    required this.type,
    required this.isVideo,
  });

  factory ProjectGalleryModel.fromMap(Map<String, dynamic> map) {
    return ProjectGalleryModel(
      id: map['id'] as int,
      imageUrl: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      isVideo: map['is_video'] as bool? ?? false,
    );
  }

  factory ProjectGalleryModel.fromJson(String source) =>
      ProjectGalleryModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final String imageUrl;
  final String type;
  final bool isVideo;
  ProjectGalleryModel copyWith({
    int? id,
    String? imageUrl,
    String? type,
    bool? isVideo,
  }) {
    return ProjectGalleryModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      isVideo: isVideo ?? this.isVideo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': imageUrl,
      'type': type,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ProjectGalleryModel(id: $id, imageUrl: $imageUrl, type: $type)';
}
