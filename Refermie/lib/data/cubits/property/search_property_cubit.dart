import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SearchPropertyState {}

class SearchPropertyInitial extends SearchPropertyState {}

class SearchPropertyFetchProgress extends SearchPropertyState {}

class SearchPropertyProgress extends SearchPropertyState {}

class SearchPropertySuccess extends SearchPropertyState {
  SearchPropertySuccess({
    required this.searchQuery,
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.searchedroperties,
    required this.selectedFilter,
  });
  final int total;
  final int offset;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> searchedroperties;
  final FilterApply? selectedFilter;

  SearchPropertySuccess copyWith({
    int? total,
    int? offset,
    String? searchQuery,
    bool? isLoadingMore,
    bool? hasError,
    List<PropertyModel>? searchedroperties,
    FilterApply? selectedFilter,
  }) {
    return SearchPropertySuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      searchedroperties: searchedroperties ?? this.searchedroperties,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class SearchPropertyFailure extends SearchPropertyState {
  SearchPropertyFailure(this.errorMessage);
  final dynamic errorMessage;
}

class SearchPropertyCubit extends Cubit<SearchPropertyState> {
  SearchPropertyCubit() : super(SearchPropertyInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> searchProperty(
    String query, {
    required int offset,
    bool? useOffset,
    FilterApply? filter,
  }) async {
    try {
      emit(SearchPropertyFetchProgress());
      final result = await _propertyRepository.searchProperty(
        query,
        offset: 0,
        filter: filter,
      );

      emit(
        SearchPropertySuccess(
          searchQuery: query,
          total: result.total,
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          searchedroperties: result.modelList,
          selectedFilter: filter,
        ),
      );
    } on Exception catch (e) {
      emit(SearchPropertyFailure(e));
    }
  }

  void clearSearch() {
    if (state is SearchPropertySuccess) {
      emit(SearchPropertyInitial());
    }
  }

  Future<void> fetchMoreSearchData() async {
    try {
      if (state is SearchPropertySuccess) {
        if ((state as SearchPropertySuccess).isLoadingMore) {
          return;
        }
        emit((state as SearchPropertySuccess).copyWith(isLoadingMore: true));

        final result = await _propertyRepository.searchProperty(
          (state as SearchPropertySuccess).searchQuery,
          offset: (state as SearchPropertySuccess).searchedroperties.length,
          filter: (state as SearchPropertySuccess).selectedFilter,
        );

        final bookingsState = state as SearchPropertySuccess;
        bookingsState.searchedroperties.addAll(result.modelList);
        emit(
          SearchPropertySuccess(
            searchQuery: (state as SearchPropertySuccess).searchQuery,
            isLoadingMore: false,
            hasError: false,
            searchedroperties: bookingsState.searchedroperties,
            offset: (state as SearchPropertySuccess).searchedroperties.length,
            total: result.total,
            selectedFilter: (state as SearchPropertySuccess).selectedFilter,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as SearchPropertySuccess).copyWith(
          isLoadingMore: false,
          hasError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is SearchPropertySuccess) {
      return (state as SearchPropertySuccess).searchedroperties.length <
          (state as SearchPropertySuccess).total;
    }
    return false;
  }
}
