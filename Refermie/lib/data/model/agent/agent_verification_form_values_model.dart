class AgentVerificationFormValueModel {
  AgentVerificationFormValueModel({
    this.id,
    this.userId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.user,
    this.verifyCustomerValues,
  });

  AgentVerificationFormValueModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    userId = json['user_id'] as int?;
    status = json['status']?.toString() ?? '';
    createdAt = json['created_at']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
    deletedAt = json['deleted_at']?.toString() ?? '';
    user = json['user'] != null
        ? User.fromJson(json['user'] as Map<String, dynamic>)
        : null;
    if (json['verify_customer_values'] != null) {
      verifyCustomerValues = <VerifyCustomerValues>[];
      json['verify_customer_values'].forEach((dynamic v) {
        verifyCustomerValues!
            .add(VerifyCustomerValues.fromJson(v as Map<String, dynamic>));
      });
    }
  }
  int? id;
  int? userId;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  User? user;
  List<VerifyCustomerValues>? verifyCustomerValues;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (verifyCustomerValues != null) {
      data['verify_customer_values'] =
          verifyCustomerValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  User({
    this.id,
    this.name,
    this.profile,
    this.propertyCount,
    this.projectsCount,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name']?.toString() ?? '';
    profile = json['profile']?.toString() ?? '';
    propertyCount = json['property_count']?.toString() ?? '0';
    projectsCount = json['projects_count']?.toString() ?? '0';
  }
  int? id;
  String? name;
  String? profile;
  String? propertyCount;
  String? projectsCount;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profile'] = profile;
    data['property_count'] = propertyCount;
    data['projects_count'] = projectsCount;
    return data;
  }
}

class VerifyCustomerValues {
  VerifyCustomerValues({
    this.id,
    this.verifyCustomerId,
    this.verifyCustomerFormId,
    this.value,
    this.verifyForm,
  });

  VerifyCustomerValues.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    verifyCustomerId = json['verify_customer_id'] as int?;
    verifyCustomerFormId = json['verify_customer_form_id'] as int?;
    value = json['value'];
    verifyForm = json['verify_form'] != null
        ? VerifyForm.fromJson(json['verify_form'] as Map<String, dynamic>)
        : null;
  }
  int? id;
  int? verifyCustomerId;
  int? verifyCustomerFormId;
  dynamic value;
  VerifyForm? verifyForm;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['verify_customer_id'] = verifyCustomerId;
    data['verify_customer_form_id'] = verifyCustomerFormId;
    data['value'] = value;
    if (verifyForm != null) {
      data['verify_form'] = verifyForm!.toJson();
    }
    return data;
  }
}

class VerifyForm {
  VerifyForm({this.id, this.name, this.fieldType, this.formFieldsValues});

  VerifyForm.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name']?.toString() ?? '';
    fieldType = json['field_type']?.toString() ?? '';
    if (json['form_fields_values'] != null) {
      formFieldsValues = <FormFieldsValues>[];
      json['form_fields_values'].forEach((dynamic v) {
        formFieldsValues!
            .add(FormFieldsValues.fromJson(v as Map<String, dynamic>));
      });
    }
  }
  int? id;
  String? name;
  String? fieldType;
  List<FormFieldsValues>? formFieldsValues;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['field_type'] = fieldType;
    if (formFieldsValues != null) {
      data['form_fields_values'] =
          formFieldsValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FormFieldsValues {
  FormFieldsValues({this.id, this.verifyCustomerFormId, this.value});

  FormFieldsValues.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    verifyCustomerFormId = json['verify_customer_form_id'] as int?;
    value = json['value']?.toString() ?? '';
  }
  int? id;
  int? verifyCustomerFormId;
  String? value;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['verify_customer_form_id'] = verifyCustomerFormId;
    data['value'] = value;
    return data;
  }
}
