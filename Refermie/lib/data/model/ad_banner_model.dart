import 'dart:convert';

import 'package:ebroker/data/model/property_model.dart';

class AdBanner {
  AdBanner({
    this.id,
    this.page,
    this.platform,
    this.placement,
    this.image,
    this.type,
    this.externalLinkUrl,
    this.propertyId,
    this.durationDays,
    this.startsAt,
    this.endsAt,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.property,
  });

  factory AdBanner.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    return AdBanner(
      id: parseInt(json['id']),
      page: json['page']?.toString(),
      platform: json['platform']?.toString(),
      placement: json['placement']?.toString(),
      image: json['image']?.toString(),
      type: json['type']?.toString(),
      externalLinkUrl: json['external_link_url']?.toString(),
      propertyId: parseInt(json['property_id']),
      durationDays: parseInt(json['duration_days']),
      startsAt: json['starts_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
      isActive: json['is_active'] is int
          ? json['is_active'] == 1
          : json['is_active']?.toString() == '1',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      property: json['property'] != null
          ? PropertyModel.fromMap(
              json['property'] as Map<String, dynamic>? ?? {},
            )
          : null,
    );
  }

  final int? id;
  final String? page;
  final String? platform;
  final String? placement; // e.g. below_categories, above_all_properties, etc.
  final String? image;
  final String? type; // e.g. external_link, banner_only
  final String? externalLinkUrl;
  final int? propertyId;
  final int? durationDays;
  final String? startsAt;
  final String? endsAt;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final PropertyModel? property;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'page': page,
      'platform': platform,
      'placement': placement,
      'image': image,
      'type': type,
      'external_link_url': externalLinkUrl,
      'property_id': propertyId,
      'duration_days': durationDays,
      'starts_at': startsAt,
      'ends_at': endsAt,
      'is_active': isActive ?? false ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'property': property?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  /// Helper method to check if banner is currently active
  bool get isCurrentlyActive {
    if (isActive != true) return false;

    final now = DateTime.now();
    if (startsAt != null) {
      final start = DateTime.tryParse(startsAt!);
      if (start != null && now.isBefore(start)) return false;
    }
    if (endsAt != null) {
      final end = DateTime.tryParse(endsAt!);
      if (end != null && now.isAfter(end)) return false;
    }
    return true;
  }

  /// Helper method to get the link URL based on type
  String? get linkUrl {
    if (type == 'external_link') {
      return externalLinkUrl;
    }
    // For other types like 'banner_only', 'property', etc., handle accordingly
    return null;
  }
}

/// Convenience enum for placement types provided by backend
enum AdBannerPlacementType {
  belowCategories('below_categories'),
  aboveAllProperties('above_all_properties'),
  aboveSimilarProperties('above_similar_properties'),
  aboveFacilities('above_facilities');

  const AdBannerPlacementType(this.value);
  final String value;
}

/// Convenience enum for banner types
enum AdBannerType {
  externalLink('external_link'),
  bannerOnly('banner_only'),
  property('property');

  const AdBannerType(this.value);
  final String value;
}
