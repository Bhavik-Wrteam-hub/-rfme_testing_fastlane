import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/model/home_slider.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';

class HomePageDataModel implements NativeAdWidgetContainer {
  const HomePageDataModel({
    this.featuredSection,
    this.mostLikedProperties,
    this.mostViewedProperties,
    this.projectSection,
    this.sliderSection,
    this.categoriesSection,
    this.articleSection,
    this.agentsList,
    this.nearByProperties,
    this.featuredProjectSection,
    this.personalizedProperties,
    this.originalSections,
    this.premiumProperties,
    this.propertiesByCities,
    this.homePageLocationDataAvailable,
  });

  /// Empty model used as an initial state when sections are loaded separately.
  factory HomePageDataModel.empty() {
    return const HomePageDataModel(
      featuredSection: <PropertyModel>[],
      mostLikedProperties: <PropertyModel>[],
      mostViewedProperties: <PropertyModel>[],
      projectSection: <ProjectModel>[],
      sliderSection: <HomeSlider>[],
      categoriesSection: <Category>[],
      articleSection: <ArticleModel>[],
      agentsList: <AgentModel>[],
      nearByProperties: <PropertyModel>[],
      featuredProjectSection: <ProjectModel>[],
      personalizedProperties: <PropertyModel>[],
      premiumProperties: <PropertyModel>[],
      originalSections: <HomePageSection>[],
      propertiesByCities: <City>[],
      homePageLocationDataAvailable: true,
    );
  }

  final List<PropertyModel>? featuredSection;
  final List<PropertyModel>? mostLikedProperties;
  final List<PropertyModel>? mostViewedProperties;
  final List<ProjectModel>? projectSection;
  final List<HomeSlider>? sliderSection;
  final List<Category>? categoriesSection;
  final List<ArticleModel>? articleSection;
  final List<AgentModel>? agentsList;
  final List<PropertyModel>? nearByProperties;
  final List<ProjectModel>? featuredProjectSection;
  final List<PropertyModel>? personalizedProperties;
  final List<PropertyModel>? premiumProperties;
  final List<HomePageSection>? originalSections;
  final List<City>? propertiesByCities;
  final bool? homePageLocationDataAvailable;

  HomePageDataModel copyWith({
    List<PropertyModel>? featuredSection,
    List<PropertyModel>? mostLikedProperties,
    List<PropertyModel>? mostViewedProperties,
    List<ProjectModel>? projectSection,
    List<HomeSlider>? sliderSection,
    List<Category>? categoriesSection,
    List<ArticleModel>? articleSection,
    List<AgentModel>? agentsList,
    List<PropertyModel>? nearByProperties,
    List<ProjectModel>? featuredProjectSection,
    List<PropertyModel>? personalizedProperties,
    List<HomePageSection>? originalSections,
    List<PropertyModel>? premiumProperties,
    List<City>? propertiesByCities,
    bool? homePageLocationDataAvailable,
  }) {
    return HomePageDataModel(
      projectSection: projectSection ?? this.projectSection,
      mostLikedProperties: mostLikedProperties ?? this.mostLikedProperties,
      featuredSection: featuredSection ?? this.featuredSection,
      mostViewedProperties: mostViewedProperties ?? this.mostViewedProperties,
      sliderSection: sliderSection ?? this.sliderSection,
      categoriesSection: categoriesSection ?? this.categoriesSection,
      articleSection: articleSection ?? this.articleSection,
      agentsList: agentsList ?? this.agentsList,
      nearByProperties: nearByProperties ?? this.nearByProperties,
      featuredProjectSection:
          featuredProjectSection ?? this.featuredProjectSection,
      personalizedProperties:
          personalizedProperties ?? this.personalizedProperties,
      originalSections: originalSections ?? this.originalSections,
      premiumProperties: premiumProperties ?? this.premiumProperties,
      propertiesByCities: propertiesByCities ?? this.propertiesByCities,
      homePageLocationDataAvailable:
          homePageLocationDataAvailable ?? this.homePageLocationDataAvailable,
    );
  }
}

class HomePageSection {
  HomePageSection({
    this.type,
    this.title,
    this.translatedTitle,
    this.data,
    this.sectionId,
    this.sortOrder,
    this.isActive,
  });

  factory HomePageSection.fromJson(Map<String, dynamic> json) {
    return HomePageSection(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      translatedTitle: json['translated_title']?.toString(),
      data: json['data'] as List<dynamic>? ?? [],
      sectionId: json['section_id'] as int? ?? json['id'] as int?,
      sortOrder: json['sort_order'] as int?,
      isActive: json['is_active']?.toString() == '1',
    );
  }
  final String? type;
  final String? title;
  final String? translatedTitle;
  final List<dynamic>? data;
  final int? sectionId;
  final int? sortOrder;
  final bool? isActive;
}
