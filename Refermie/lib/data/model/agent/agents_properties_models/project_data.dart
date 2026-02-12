import 'package:ebroker/data/model/agent/agents_properties_models/gallary_images.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';

class ProjectData implements NativeAdWidgetContainer {
  const ProjectData({
    required this.id,
    required this.slugId,
    required this.city,
    required this.state,
    required this.country,
    required this.title,
    required this.translatedTitle,
    required this.type,
    required this.image,
    required this.location,
    required this.galleryImages,
    required this.categoryId,
    required this.category,
    required this.isFeatured,
    required this.addedBy,
    this.lowQualityImage,
  });

  ProjectData.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      slugId = json['slug_id']?.toString() ?? '',
      city = json['city']?.toString() ?? '',
      state = json['state']?.toString() ?? '',
      country = json['country']?.toString() ?? '',
      title = json['title']?.toString() ?? '',
      translatedTitle = json['translated_title']?.toString() ?? '',
      type = json['type']?.toString() ?? '',
      image = json['image']?.toString() ?? '',
      lowQualityImage = json['low_quality_image']?.toString(),
      location = json['location']?.toString() ?? '',
      category = Category.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      categoryId = json['category_id'] as int,
      galleryImages = (json['gallary_images'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map<GalleryImages>(GalleryImages.fromJson)
          .toList(),
      addedBy = json['added_by']?.toString() ?? '',
      isFeatured = json['is_promoted'] as bool? ?? false;

  final int id;
  final String slugId;
  final String city;
  final String state;
  final String country;
  final String title;
  final String? translatedTitle;
  final String type;
  final String image;
  final String? lowQualityImage;
  final String location;
  final List<GalleryImages> galleryImages;
  final int categoryId;
  final Category category;
  final bool isFeatured;
  final String addedBy;
}
