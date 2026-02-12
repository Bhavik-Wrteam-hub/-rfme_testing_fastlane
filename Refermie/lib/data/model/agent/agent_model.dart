import 'package:ebroker/utils/admob/native_ad_manager.dart';

class AgentModel implements NativeAdWidgetContainer {
  const AgentModel({
    required this.id,
    required this.name,
    required this.profile,
    required this.email,
    required this.projectsCount,
    required this.propertyCount,
    required this.mobile,
    required this.isVerified,
    required this.isAdmin,
  });

  AgentModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name']?.toString() ?? '',
        profile = json['profile']?.toString() ?? '',
        email = json['email']?.toString() ?? '',
        mobile = json['mobile']?.toString() ?? '',
        projectsCount = json['projects_count']?.toString() ?? '0',
        propertyCount = json['property_count']?.toString() ?? '0',
        isVerified = json['is_verified'] as bool? ?? false,
        isAdmin = json['is_admin'] as bool? ?? false;

  final int id;
  final String name;
  final String profile;
  final String email;
  final String projectsCount;
  final String propertyCount;
  final String mobile;
  final bool isVerified;
  final bool isAdmin;

  AgentModel copywith({
    int? id,
    String? name,
    String? profile,
    String? email,
    String? projectsCount,
    String? propertyCount,
    String? mobile,
    bool? isVerified,
    bool? isAdmin,
  }) =>
      AgentModel(
        id: id ?? this.id,
        name: name ?? this.name,
        profile: profile ?? this.profile,
        email: email ?? this.email,
        projectsCount: projectsCount ?? this.projectsCount,
        propertyCount: propertyCount ?? this.propertyCount,
        mobile: mobile ?? this.mobile,
        isVerified: isVerified ?? this.isVerified,
        isAdmin: isAdmin ?? this.isAdmin,
      );
}
