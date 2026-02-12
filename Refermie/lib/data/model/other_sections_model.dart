import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/home_slider.dart';
import 'package:ebroker/data/model/property_model.dart';

class OtherSectionsModel {
  OtherSectionsModel({
    required this.categories,
    required this.agents,
    required this.articles,
    required this.userRecommendations,
    required this.faqsRaw,
    required this.slider,
    required this.locationBasedData,
    this.categoriesSectionId,
    this.agentsSectionId,
    this.articlesSectionId,
    this.userRecommendationsSectionId,
    this.faqsSectionId,
    this.sliderSectionId,
  });

  factory OtherSectionsModel.fromApiResponse(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const {};

    final categories = _parseSectionList<Category>(
      data['categories'],
      Category.fromJson,
    );
    final agents = _parseSectionList<AgentModel>(
      data['agents'],
      AgentModel.fromJson,
    );
    final articles = _parseSectionList<ArticleModel>(
      data['articles'],
      ArticleModel.fromJson,
    );
    final userRecommendations = _parseSectionList<PropertyModel>(
      data['user_recommendations'],
      PropertyModel.fromMap,
    );
    // FAQ model differs across codebases; keep raw maps for now to avoid breaking.
    final faqs = _parseSectionList<Map<String, dynamic>>(
      data['faqs'],
      (m) => m,
    );
    final slider = _parseSectionList<HomeSlider>(
      data['slider'],
      HomeSlider.fromJson,
    );

    return OtherSectionsModel(
      categories: categories.items,
      agents: agents.items,
      articles: articles.items,
      userRecommendations: userRecommendations.items,
      faqsRaw: faqs.items,
      slider: slider.items,
      locationBasedData: data['location_based_data'] as bool? ?? false,
      categoriesSectionId: categories.sectionId,
      agentsSectionId: agents.sectionId,
      articlesSectionId: articles.sectionId,
      userRecommendationsSectionId: userRecommendations.sectionId,
      faqsSectionId: faqs.sectionId,
      sliderSectionId: slider.sectionId,
    );
  }

  final List<Category> categories;
  final List<AgentModel> agents;
  final List<ArticleModel> articles;
  final List<PropertyModel> userRecommendations;
  final List<Map<String, dynamic>> faqsRaw;
  final List<HomeSlider> slider;
  final bool locationBasedData;

  final int? categoriesSectionId;
  final int? agentsSectionId;
  final int? articlesSectionId;
  final int? userRecommendationsSectionId;
  final int? faqsSectionId;
  final int? sliderSectionId;
}

({int? sectionId, List<T> items}) _parseSectionList<T>(
  dynamic node,
  T Function(Map<String, dynamic>) fromMap,
) {
  if (node is! Map) return (sectionId: null, items: <T>[]);
  final map = node.cast<String, dynamic>();
  final sectionId = map['section_id'] as int?;
  final list = (map['data'] as List? ?? const [])
      .whereType<Map<dynamic, dynamic>>()
      .map((e) => fromMap(Map<String, dynamic>.from(e)))
      .toList();
  return (sectionId: sectionId, items: list);
}
