import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';

import 'package:ebroker/exports/main_export.dart';

abstract class ManageProjectState {}

class ManageProjectIntial extends ManageProjectState {}

class ManageProjectInProgress extends ManageProjectState {}

class ManageProjectInSuccess extends ManageProjectState {
  ManageProjectInSuccess(this.project);
  final ProjectModel project;
}

class ManageProjectInFail extends ManageProjectState {
  ManageProjectInFail(this.error);
  final dynamic error;
}

enum ManageProjectType { create, update }

class ManageProjectCubit extends Cubit<ManageProjectState> {
  ManageProjectCubit() : super(ManageProjectIntial());
  final ProjectRepository _projectRepository = ProjectRepository();
  Future<void> manage({
    required ManageProjectType type,
    required Map<String, dynamic> data,
  }) async {
    try {
      emit(ManageProjectInProgress());
      final response = await _projectRepository.createProject(data);
      final responseData = response?['data'][0] as Map<String, dynamic>? ?? {};
      emit(ManageProjectInSuccess(ProjectModel.fromMap(responseData)));
    } on Exception catch (e, st) {
      emit(
        ManageProjectInFail('$e \n $st'),
      );
    }
  }
}
