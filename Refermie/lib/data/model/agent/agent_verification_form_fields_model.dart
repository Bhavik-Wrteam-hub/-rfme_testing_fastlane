class AgentVerificationFormFieldsModel {
  AgentVerificationFormFieldsModel({
    required this.id,
    required this.name,
    required this.translatedName,
    required this.fieldType,
    required this.formFieldsValues,
  });

  factory AgentVerificationFormFieldsModel.fromJson(Map<String, dynamic> json) {
    return AgentVerificationFormFieldsModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      translatedName: json['translated_name']?.toString() ?? '',
      fieldType: json['field_type']?.toString() ?? '',
      formFieldsValues: List<FormFieldValue>.from(
        (json['form_fields_values'] as List).map(
          (x) => FormFieldValue.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }
  final int id;
  final String name;
  final String? translatedName;
  final String fieldType;
  final List<FormFieldValue> formFieldsValues;
}

class FormFieldValue {
  FormFieldValue({
    required this.id,
    required this.verifyCustomerFormId,
    required this.value,
    required this.translatedValue,
  });

  factory FormFieldValue.fromJson(Map<String, dynamic> json) {
    return FormFieldValue(
      id: json['id'] as int,
      verifyCustomerFormId: json['verify_customer_form_id'] as int,
      value: json['value']?.toString() ?? '',
      translatedValue: json['translated_value']?.toString() ?? '',
    );
  }
  final int id;
  final int verifyCustomerFormId;
  final String value;
  final String? translatedValue;
}
