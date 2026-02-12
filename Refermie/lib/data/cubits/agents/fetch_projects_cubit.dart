import 'package:ebroker/data/model/agent/agents_property_model.dart';
import 'package:ebroker/data/repositories/agents_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchAgentsProjectState {}

final class FetchAgentsProjectInitial extends FetchAgentsProjectState {}

final class FetchAgentsProjectLoading extends FetchAgentsProjectState {}

final class FetchAgentsProjectSuccess extends FetchAgentsProjectState {
  FetchAgentsProjectSuccess({
    required this.offset,
    required this.total,
    required this.agentsProperty,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final AgentPropertyProjectModel agentsProperty;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  FetchAgentsProjectSuccess copyWith({
    AgentPropertyProjectModel? agentsProperty,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchAgentsProjectSuccess(
      agentsProperty: agentsProperty ?? this.agentsProperty,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

final class FetchAgentsProjectFailure extends FetchAgentsProjectState {
  FetchAgentsProjectFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchAgentsProjectCubit extends Cubit<FetchAgentsProjectState> {
  FetchAgentsProjectCubit() : super(FetchAgentsProjectInitial());

  final AgentsRepository agentsRepository = AgentsRepository();

  Future<void> fetchAgentsProject({
    required bool forceRefresh,
    required String agentId,
    required bool isAdmin,
  }) async {
    try {
      emit(FetchAgentsProjectLoading());
      final (:total, :agentsProperty) =
          await agentsRepository.fetchAgentProjects(
        offset: 0,
        isProjects: 1,
        agentId: agentId,
        isAdmin: isAdmin,
      );
      emit(
        FetchAgentsProjectSuccess(
          offset: 0,
          total: total,
          agentsProperty: agentsProperty,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchAgentsProjectFailure(e));
    }
  }

  bool isLoadingMore() {
    if (state is FetchAgentsProjectSuccess) {
      return (state as FetchAgentsProjectSuccess).isLoadingMore;
    }
    return false;
  }

  Future<void> fetchMore({required bool isAdmin}) async {
    if (state is FetchAgentsProjectSuccess) {
      try {
        final scrollSuccess = state as FetchAgentsProjectSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchAgentsProjectSuccess).copyWith(isLoadingMore: true),
        );

        final (:total, :agentsProperty) =
            await agentsRepository.fetchAgentProjects(
          offset: (state as FetchAgentsProjectSuccess)
              .agentsProperty
              .projectData
              .length,
          isProjects: 1,
          agentId: (state as FetchAgentsProjectSuccess)
              .agentsProperty
              .customerData
              .id
              .toString(),
          isAdmin: isAdmin,
        );

        final currentState = state as FetchAgentsProjectSuccess;

        emit(
          FetchAgentsProjectSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            agentsProperty: currentState.agentsProperty.copyWith(
              projectData: [
                ...currentState.agentsProperty.projectData,
                ...agentsProperty.projectData,
              ],
            ),
            offset: (state as FetchAgentsProjectSuccess)
                .agentsProperty
                .projectData
                .length,
            total: total,
          ),
        );
      } on ApiException {
        emit(
          (state as FetchAgentsProjectSuccess).copyWith(hasLoadMoreError: true),
        );
      }
    }
  }

  bool hasMoreData() {
    if (state is FetchAgentsProjectSuccess) {
      final agentsProperty =
          (state as FetchAgentsProjectSuccess).agentsProperty;
      final total = (state as FetchAgentsProjectSuccess).total;
      return agentsProperty.projectData.length < total;
    }
    return false;
  }
}
