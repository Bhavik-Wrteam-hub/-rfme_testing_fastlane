class InterestedUserModel {
  InterestedUserModel({
    this.id,
    this.name,
    this.image,
    this.email,
    this.mobile,
    this.customertotalpost,
    this.runtimeTypeLog,
  });

  InterestedUserModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'] as int;
      name = json['name']?.toString() ?? '';
      image = json['profile']?.toString() ?? '';
      email = json['email']?.toString() ?? '';
      mobile = json['mobile']?.toString() ?? '';
      customertotalpost = json['customertotalpost']?.toString() ?? '0';
      runtimeTypeLog =
          json.map((key, value) => MapEntry(key, value.runtimeType)).toString();
    } on Exception catch (_) {
      runtimeTypeLog =
          json.map((key, value) => MapEntry(key, value.runtimeType)).toString();
    }
  }
  int? id;
  String? name;
  String? image;
  String? email;
  String? mobile;
  String? customertotalpost;
  String? runtimeTypeLog;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profile'] = image;
    data['email'] = email;
    data['mobile'] = mobile;
    data['customertotalpost'] = customertotalpost;
    return data;
  }
}
