import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChangeProjectStatusState {}

class ChangeProjectStatusInitial extends ChangeProjectStatusState {}

class ChangeProjectStatusInProgress extends ChangeProjectStatusState {}

class ChangeProjectStatusSuccess extends ChangeProjectStatusState {
  ChangeProjectStatusSuccess();

  ChangeProjectStatusSuccess copyWith({
    String? message,
  }) {
    return ChangeProjectStatusSuccess();
  }
}

class ChangeProjectStatusFailure extends ChangeProjectStatusState {
  ChangeProjectStatusFailure(this.error);
  final String error;
}

class ChangeProjectStatusCubit extends Cubit<ChangeProjectStatusState> {
  ChangeProjectStatusCubit() : super(ChangeProjectStatusInitial());

  final ProjectRepository _projectRepository = ProjectRepository();

  Future<void> enableProject({
    required int projectId,
    required int status,
  }) async {
    try {
      emit(ChangeProjectStatusInProgress());
      final result = await _projectRepository.changeProjectStatus(
        projectId: projectId,
        status: status,
      );
      if (result['error'] == true) {
        emit(ChangeProjectStatusFailure(result['message']?.toString() ?? ''));
      } else {
        emit(
          ChangeProjectStatusSuccess(),
        );
      }
    } on Exception catch (e) {
      emit(ChangeProjectStatusFailure(e.toString()));
    }
  }
}
