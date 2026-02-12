class Company {
  Company({
    this.companyName,
    this.companyWebsite,
    this.companyEmail,
    this.companyAddress,
    this.companyTel1,
    this.companyTel2,
  });

  Company.fromJson(Map<String, dynamic> json) {
    companyName = json['company_name']?.toString() ?? '';
    companyWebsite = json['company_website']?.toString() ?? '';
    companyEmail = json['company_email']?.toString() ?? '';
    companyAddress = json['company_address']?.toString() ?? '';
    companyTel1 = json['company_tel1']?.toString() ?? '';
    companyTel2 = json['company_tel2']?.toString() ?? '';
  }
  String? companyName;
  String? companyWebsite;
  String? companyEmail;
  String? companyAddress;
  String? companyTel1;
  String? companyTel2;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['company_name'] = companyName;
    data['company_website'] = companyWebsite;
    data['company_email'] = companyEmail;
    data['company_address'] = companyAddress;
    data['company_tel1'] = companyTel1;
    data['company_tel2'] = companyTel2;
    return data;
  }
}
