import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/model/property_model.dart';

class AdvertisementProperty {
  AdvertisementProperty({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.propertyId,
    required this.property,
  });

  factory AdvertisementProperty.fromJson(Map<String, dynamic> json) =>
      AdvertisementProperty(
        id: json['id'] as int,
        status: json['status']?.toString() ?? '0',
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? '',
        propertyId: json['property_id']?.toString() ?? '',
        property: PropertyModel.fromMap(
            json['property'] as Map<String, dynamic>? ?? {}),
      );
  final int id;
  final String status;
  final String startDate;
  final String endDate;
  final String propertyId;
  final PropertyModel property;

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'property_id': propertyId,
        'property': property.toMap(),
      };
}

class AdvertisementProject {
  AdvertisementProject({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.projectId,
    required this.project,
  });

  factory AdvertisementProject.fromJson(Map<String, dynamic> json) =>
      AdvertisementProject(
        id: json['id'] as int,
        status: json['status']?.toString() ?? '0',
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? '',
        projectId: json['project_id'].toString(),
        project: ProjectModel.fromMap(
            json['project'] as Map<String, dynamic>? ?? {}),
      );
  final int id;
  final String status;
  final String startDate;
  final String endDate;
  final String projectId;
  final ProjectModel project;

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'project_id': projectId,
        'Project': project.toMap(),
      };
}
