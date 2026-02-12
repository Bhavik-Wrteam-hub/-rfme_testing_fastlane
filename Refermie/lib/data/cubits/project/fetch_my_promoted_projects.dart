import 'dart:developer';

import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMyPromotedProjectsState {}

class FetchMyPromotedProjectsInitial extends FetchMyPromotedProjectsState {}

class FetchMyPromotedProjectsInProgress extends FetchMyPromotedProjectsState {}

class FetchMyPromotedProjectsSuccess extends FetchMyPromotedProjectsState {
  FetchMyPromotedProjectsSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.advertisement,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<AdvertisementProject> advertisement;
  final int offset;
  final int total;

  FetchMyPromotedProjectsSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<AdvertisementProject>? advertisement,
    int? offset,
    int? total,
  }) {
    return FetchMyPromotedProjectsSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      advertisement: advertisement ?? this.advertisement,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchMyPromotedProjectsFailure extends FetchMyPromotedProjectsState {
  FetchMyPromotedProjectsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchMyPromotedProjectsCubit extends Cubit<FetchMyPromotedProjectsState> {
  FetchMyPromotedProjectsCubit() : super(FetchMyPromotedProjectsInitial());

  final ProjectRepository _projectRepository = ProjectRepository();

  Future<void> fetchMyPromotedProjects() async {
    try {
      emit(FetchMyPromotedProjectsInProgress());

      final result = await _projectRepository.fetchMyPromotedProjects();

      emit(
        FetchMyPromotedProjectsSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          advertisement: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } on Exception catch (e, st) {
      log(e.toString());
      log(st.toString());
      emit(FetchMyPromotedProjectsFailure(e));
    }
  }

  void delete(dynamic id) {
    if (state is FetchMyPromotedProjectsSuccess) {
      final projectModel = (state as FetchMyPromotedProjectsSuccess)
          .advertisement
        ..removeWhere((element) => element.id == id);

      emit(
        (state as FetchMyPromotedProjectsSuccess)
            .copyWith(advertisement: projectModel),
      );
    }
  }

  Future<void> fetchMyPromotedProjectsMore() async {
    try {
      if (state is FetchMyPromotedProjectsSuccess) {
        if ((state as FetchMyPromotedProjectsSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchMyPromotedProjectsSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _projectRepository.fetchMyPromotedProjects();

        final projectModelState = state as FetchMyPromotedProjectsSuccess;
        projectModelState.advertisement.addAll(result.modelList);
        emit(
          FetchMyPromotedProjectsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            advertisement: projectModelState.advertisement,
            offset:
                (state as FetchMyPromotedProjectsSuccess).advertisement.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchMyPromotedProjectsSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchMyPromotedProjectsSuccess) {
      return (state as FetchMyPromotedProjectsSuccess).advertisement.length <
          (state as FetchMyPromotedProjectsSuccess).total;
    }
    return false;
  }

  void update(AdvertisementProject model) {
    if (state is FetchMyPromotedProjectsSuccess) {
      final properties =
          (state as FetchMyPromotedProjectsSuccess).advertisement;

      final index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchMyPromotedProjectsSuccess)
            .copyWith(advertisement: properties),
      );
    }
  }
}
