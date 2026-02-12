import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/repositories/category_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/network/cache_manger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchCategoryState {}

class FetchCategoryInitial extends FetchCategoryState {}

class FetchCategoryInProgress extends FetchCategoryState {}

class FetchCategorySuccess extends FetchCategoryState {
  FetchCategorySuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<Category> categories;

  FetchCategorySuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasError,
    List<Category>? categories,
  }) {
    return FetchCategorySuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'offset': offset,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'categories': categories.map((x) => x.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return '''FetchCategorySuccess(total: $total, offset: $offset, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)''';
  }
}

class FetchCategoryFailure extends FetchCategoryState {
  FetchCategoryFailure(this.errorMessage);
  final String errorMessage;
}

class FetchCategoryCubit extends Cubit<FetchCategoryState> {
  FetchCategoryCubit() : super(FetchCategoryInitial());

  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<void> fetchCategories({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      await CacheData().getData<FetchCategorySuccess>(
        forceRefresh: forceRefresh ?? false,
        delay: loadWithoutDelay ?? false ? 0 : null,
        onProgress: () {
          emit(FetchCategoryInProgress());
        },
        onNetworkRequest: () async {
          final categories = await _categoryRepository.fetchCategories(
            offset: 0,
          );

          return FetchCategorySuccess(
            total: categories.total,
            categories: categories.modelList,
            offset: 0,
            hasError: false,
            isLoadingMore: false,
          );
        },
        onOfflineData: () {
          return state as FetchCategorySuccess;
        },
        onSuccess: (data) {
          emit(data);
        },
        hasData: state is FetchCategorySuccess,
      );
    } on ApiException catch (e) {
      emit(FetchCategoryFailure(e.toString()));
    }
  }

  Future<Category> get(int id) async {
    try {
      if (state is FetchCategorySuccess) {
        final category = (state as FetchCategorySuccess).categories.firstWhere(
              (element) => element.id == id,
            );
        return category;
      }
      final dataOutput = await _categoryRepository.fetchCategories(
        offset: 0,
        id: id,
      );
      return dataOutput.modelList.first;
    } on Exception catch (_) {
      rethrow;
    }
  }

  List<Category> getCategories() {
    if (state is FetchCategorySuccess) {
      return (state as FetchCategorySuccess).categories;
    }

    return <Category>[];
  }

  Future<void> fetchCategoriesMore() async {
    try {
      if (state is FetchCategorySuccess) {
        if ((state as FetchCategorySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchCategorySuccess).copyWith(isLoadingMore: true));
        final result = await _categoryRepository.fetchCategories(
          offset: (state as FetchCategorySuccess).categories.length,
        );

        final categoryState = state as FetchCategorySuccess;
        categoryState.categories.addAll(result.modelList);

        emit(
          FetchCategorySuccess(
            isLoadingMore: false,
            hasError: false,
            categories: categoryState.categories,
            offset: (state as FetchCategorySuccess).categories.length,
            total: result.total,
          ),
        );
      }
    } on ApiException {
      emit(
        (state as FetchCategorySuccess).copyWith(
          isLoadingMore: false,
          hasError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchCategorySuccess) {
      return (state as FetchCategorySuccess).categories.length <
          (state as FetchCategorySuccess).total;
    }
    return false;
  }
}
