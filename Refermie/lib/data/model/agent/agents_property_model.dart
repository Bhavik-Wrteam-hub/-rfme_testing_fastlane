import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/project_data.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/properties_data.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';

class AgentPropertyProjectModel implements NativeAdWidgetContainer {
  const AgentPropertyProjectModel({
    required this.customerData,
    required this.propertiesData,
    required this.projectData,
    required this.premiumPropertyCount,
    required this.isPackageAvailable,
    required this.isFeatureAvailable,
  });

  AgentPropertyProjectModel.fromJson(Map<String, dynamic> json)
      : projectData = (json['projects_data'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ProjectData.fromJson)
            .toList(),
        propertiesData = (json['properties_data'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(PropertiesData.fromJson)
            .toList(),
        customerData = CustomerData.fromJson(
          json['customer_data'] as Map<String, dynamic>,
        ),
        premiumPropertyCount =
            json['premium_properties_count']?.toString() ?? '0',
        isPackageAvailable = json['package_available'] as bool? ?? false,
        isFeatureAvailable = json['feature_available'] as bool? ?? false;

  final List<ProjectData> projectData;
  final List<PropertiesData> propertiesData;
  final CustomerData customerData;
  final String premiumPropertyCount;
  final bool isPackageAvailable;
  final bool isFeatureAvailable;

  AgentPropertyProjectModel copyWith({
    List<ProjectData>? projectData,
    List<PropertiesData>? propertiesData,
    CustomerData? customerData,
    String? premiumPropertyCount,
    bool? isPackageAvailable,
    bool? isFeatureAvailable,
  }) {
    return AgentPropertyProjectModel(
      projectData: projectData ?? this.projectData,
      propertiesData: propertiesData ?? this.propertiesData,
      customerData: customerData ?? this.customerData,
      premiumPropertyCount: premiumPropertyCount ?? this.premiumPropertyCount,
      isPackageAvailable: isPackageAvailable ?? this.isPackageAvailable,
      isFeatureAvailable: isFeatureAvailable ?? this.isFeatureAvailable,
    );
  }
}
