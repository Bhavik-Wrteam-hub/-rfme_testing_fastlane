import 'package:ebroker/exports/main_export.dart';

abstract class CustomField<T> {
  ///id
  dynamic id;

  //this will be to use context [not set now, it will be implement by implementing classes]
  late BuildContext context;

  //to update state
  late void Function(VoidCallback fn) update;

  ///data
  Map<String, dynamic> data = {};

  ///init field
  void init() {}

  ///dispose required resourses
  void dispose() {}

  ///this is to return value which you want to set in api
  T backValue();
  abstract String type;
  Widget render(BuildContext context);
}

class RenderCustomFields extends StatefulWidget {
  const RenderCustomFields({
    required this.field,
    required this.data,
    required this.index,
    required this.isRequired,
    super.key,
  });
  final int index;
  final CustomField<dynamic> field;
  final Map<String, dynamic> data;
  final bool isRequired;

  dynamic getId() {
    return field.id;
  }

  dynamic getValue() {
    return field.backValue();
  }

  void dispose() {
    field.dispose();
  }

  @override
  State<RenderCustomFields> createState() => _RenderCustomFieldsState();
}

class _RenderCustomFieldsState extends State<RenderCustomFields> {
  @override
  void initState() {
    widget.field.update = setState;
    widget.field.data = widget.data;
    widget.field.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.field.update = setState;
    widget.field.context = context;
    widget.field.data = widget.data;

    return Container(
      padding: EdgeInsets.only(top: widget.index == 0 ? 0 : 10, bottom: 10),
      child: widget.field.render(context),
    );
  }
}

class BlankField extends CustomField<dynamic> {
  @override
  String type = 'blank';

  @override
  Widget render(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Null backValue() {
    return null;
  }
}

class KRegisteredFields {
  final List<dynamic> _fields = [
    CustomTextField(),
    CustomNumberField(),
    CustomTextAreaField(),
    CustomDropdownField(),
    CustomRadioField(),
    CheckboxField(),
    CustomFileField(),
  ];

  CustomField<dynamic>? get(String type) {
    CustomField<dynamic>? selectedField;
    for (final field in _fields.cast<CustomField<dynamic>>()) {
      if (field.type == type) {
        selectedField = field;
      }
    }

    return selectedField;
  }
}
// fieldType == "textarea"
// fieldType == 'textbox'
// fieldType == 'number'
// fieldType == 'dropdown'
// fieldType == 'radiobutton'
// fieldType == "checkbox"
// fieldType == "file"
