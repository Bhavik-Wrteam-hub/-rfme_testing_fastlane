import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/area_calculator.dart';
import 'package:flutter/material.dart';

class AreaCalculator extends StatefulWidget {
  const AreaCalculator({super.key});

  static Route<dynamic> route(RouteSettings settings) {
    return CupertinoPageRoute(builder: (_) => const AreaCalculator());
  }

  @override
  State<AreaCalculator> createState() => _AreaCalculatorState();
}

class _AreaCalculatorState extends State<AreaCalculator> {
  final List<String> values = UnitTypes.values.map((e) => e.name).toList();

  final _formKey = GlobalKey<FormState>();
  final _fromUnit = ValueNotifier<String>('');
  final _toUnit = ValueNotifier<String>('');
  final _fromTextController = TextEditingController();
  final _toTextController = TextEditingController();
  final _resultController = TextEditingController(text: '00');

  @override
  void initState() {
    super.initState();
    _fromUnit.value = values[0];
    _toUnit.value = values[1];
  }

  @override
  void dispose() {
    _fromUnit.dispose();
    _toUnit.dispose();
    _fromTextController.dispose();
    _toTextController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'areaConvertor'.translate(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              ValueListenableBuilder(
                valueListenable: _fromUnit,
                builder: (_, fromVal, _) {
                  return ValueListenableBuilder(
                    valueListenable: _toUnit,
                    builder: (_, toVal, _) {
                      return CustomText(
                        "${"convert".translate(context)} ${fromVal.translate(context)} ${'to'.translate(context)} ${toVal.translate(context)}",
                        fontSize: context.font.md,
                        color: context.color.textColorDark,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 4.rh(context)),
              CustomText(
                'enterValueOrSelectUnit'.translate(context),
                fontSize: context.font.xs,
                color: context.color.textLightColor,
              ),
              SizedBox(height: 12.rh(context)),

              // FROM Input
              _buildField(
                context,
                hint: 'from',
                controller: _fromTextController,
                unitNotifier: _fromUnit,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldMustNotBeEmpty'.translate(context);
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.rh(context)),

              // TO Output
              _buildField(
                context,
                hint: 'to',
                controller: _toTextController,
                unitNotifier: _toUnit,
                isReadOnly: true,
              ),
              SizedBox(height: 20.rh(context)),

              // Result
              CustomTextFormField(
                isReadOnly: true,
                controller: _resultController,
                fillColor: context.color.textColorDark.withValues(alpha: 0.03),
              ),
              SizedBox(height: 20.rh(context)),

              // Convert Button
              UiUtils.buildButton(
                context,
                buttonTitle: 'convert'.translate(context),
                onPressed: _onConvertPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConvertPressed() {
    if (_formKey.currentState?.validate() != true) return;

    final input = double.tryParse(_fromTextController.text);
    if (input == null) return;

    final result = AreaConverter().convert(
      input,
      from: getEnum(_fromUnit.value),
      to: getEnum(_toUnit.value),
    );

    _toTextController.text = result.toString();
    _resultController.text =
        '${_fromTextController.text} ${_fromUnit.value.translate(context)} = $result ${_toUnit.value.translate(context)}';
  }

  Widget _buildField(
    BuildContext context, {
    required String hint,
    required TextEditingController controller,
    required ValueNotifier<String> unitNotifier,
    bool isReadOnly = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 48.rh(context),
      decoration: BoxDecoration(
        color: context.color.textColorDark.withValues(alpha: 0.03),
        border: Border.all(color: context.color.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: isReadOnly,
              validator: validator,
              style: TextStyle(color: context.color.textColorDark),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
              onChanged: (value) {
                setState(() {});
                _onConvertPressed();
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint.translate(context),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 0,
            color: context.color.textColorDark.withValues(alpha: 0.3),
            indent: 8,
            endIndent: 8,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: unitNotifier,
              builder: (_, val, _) {
                return DropdownButton<String>(
                  dropdownColor: context.color.secondaryColor,
                  value: val,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: values.map((v) {
                    return DropdownMenuItem(
                      value: v,
                      child: CustomText(v.translate(context)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => unitNotifier.value = v!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
