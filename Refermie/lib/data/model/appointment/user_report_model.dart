class UserReportModel {
  UserReportModel({
    required this.id,
    required this.isAdminData,
    required this.adminId,
    required this.agentId,
    required this.userId,
    required this.status,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    return UserReportModel(
      id: json['id']?.toString() ?? '',
      isAdminData: json['is_admin_data']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: ReportUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
  final String id;
  final String isAdminData;
  final String adminId;
  final String agentId;
  final String userId;
  final String status;
  final String reason;
  final String createdAt;
  final String updatedAt;
  final ReportUser user;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_admin_data': isAdminData,
      'admin_id': adminId,
      'agent_id': agentId,
      'user_id': userId,
      'status': status,
      'reason': reason,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user.toJson(),
    };
  }
}

class ReportUser {
  ReportUser({
    required this.id,
    required this.name,
    required this.profile,
  });

  factory ReportUser.fromJson(Map<String, dynamic> json) {
    return ReportUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
    );
  }
  final String id;
  final String name;
  final String profile;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile': profile,
    };
  }
}
