import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';

class ArticlesRepository {
  Future<DataOutput<ArticleModel>> fetchArticles({
    required int offset,
  }) async {
    final parameters = <String, dynamic>{
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
    };

    final result = await Api.get(
      url: Api.getArticles,
      queryParameters: parameters,
    );

    final modelList = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ArticleModel>(ArticleModel.fromJson)
        .toList();

    return DataOutput<ArticleModel>(
      total: int.parse(result['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<ArticleModel>> fetchArticlesById(
    String id,
  ) async {
    final parameters = <String, dynamic>{'id': id};

    final result = await Api.get(
      url: Api.getArticles,
      queryParameters: parameters,
    );
    final modelList = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ArticleModel>(ArticleModel.fromJson)
        .toList();

    return DataOutput<ArticleModel>(
      total: int.parse(result['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<ArticleModel> fetchBySlug(String slug) async {
    final result = await Api.get(
      url: Api.getArticles,
      queryParameters: {'slug_id': slug},
    );

    // Ensure 'data' is a List and safely extract the first item
    final data = result['data'];
    if (data is List && data.isNotEmpty) {
      final firstItem = data.first;
      if (firstItem is Map<String, dynamic>) {
        return ArticleModel.fromJson(firstItem);
      }
    }

    // Handle cases where data is null or in an unexpected format
    throw Exception('Invalid data format received');
  }
}
