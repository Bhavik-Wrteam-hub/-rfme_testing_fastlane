import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/data/repositories/articles_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchSingleArticleState {}

class FetchSingleArticleInitial extends FetchSingleArticleState {}

class FetchSingleArticleInProgress extends FetchSingleArticleState {}

class FetchSingleArticleSuccess extends FetchSingleArticleState {
  FetchSingleArticleSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.articlemodel,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final ArticleModel articlemodel;
  final int offset;
  final int total;

  FetchSingleArticleSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    ArticleModel? articlemodel,
    int? offset,
    int? total,
  }) {
    return FetchSingleArticleSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      articlemodel: articlemodel ?? this.articlemodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchSingleArticleFailure extends FetchSingleArticleState {
  FetchSingleArticleFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchSingleArticleCubit extends Cubit<FetchSingleArticleState> {
  FetchSingleArticleCubit() : super(FetchSingleArticleInitial());

  final ArticlesRepository _articleRepository = ArticlesRepository();

  Future<void> fetchArticlesById(String id) async {
    try {
      emit(FetchSingleArticleInProgress());

      final result = await _articleRepository.fetchArticlesById(id);

      emit(
        FetchSingleArticleSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          articlemodel: result.modelList.first,
          offset: 0,
          total: result.total,
        ),
      );
    } on Exception catch (e) {
      emit(FetchSingleArticleFailure(e));
    }
  }

  Future<void> fetchArticlesBySlug(String slug) async {
    try {
      emit(FetchSingleArticleInProgress());

      final result = await _articleRepository.fetchBySlug(slug);

      emit(
        FetchSingleArticleSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          articlemodel: result,
          offset: 0,
          total: 1,
        ),
      );
    } on Exception catch (e) {
      emit(FetchSingleArticleFailure(e));
    }
  }
}
