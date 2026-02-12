import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CustomFileField extends CustomField<dynamic> {
  @override
  String type = 'file';

  // Add state variables
  String? _pickedFilePath;
  MultipartFile? _selectedFile;
  bool _isFileSelected = false;

  String? get pickedFilePath => _pickedFilePath;
  MultipartFile? get selectedFile => _selectedFile;

  @override
  MultipartFile? backValue() {
    return _selectedFile;
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final file = File(result.files.single.path!);

        // Update the file information
        _pickedFilePath = file.path;
        _selectedFile = await MultipartFile.fromFile(file.path);
        _isFileSelected = true;

        // Trigger rebuild
        update(() {});
      }
    } on Exception catch (e) {
      log('Error picking file: $e');
      // You might want to show an error message to the user here
    }
  }

  @override
  void init() {
    id = data['id'];
    // Initialize with existing value if available
    if (data['value'] != null && data['value'].toString().isNotEmpty) {
      _pickedFilePath = data['value'].toString();
      _isFileSelected = true;
    }
    super.init();
  }

  @override
  Widget render(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              width: 32.rw(context),
              height: 32.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomImage(
                imageUrl: data['image']?.toString() ?? '',
              ),
            ),
            SizedBox(width: 8.rw(context)),
            Flexible(
              child: CustomText(
                data['translated_name']?.toString() ??
                    data['name']?.toString() ??
                    '',
                fontWeight: .w400,
                fontSize: context.font.sm,
                color: context.color.textColorDark,
              ),
            ),
            if (data['is_required'] == 1) ...[
              const SizedBox(width: 4),
              CustomText('*', color: context.color.error),
            ],
          ],
        ),
        SizedBox(height: 8.rh(context)),
        GestureDetector(
          onTap: pickFile,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(4),
              color: context.color.textLightColor,
              strokeCap: .round,
              padding: const EdgeInsets.all(4),
              dashPattern: const [3, 3],
            ),
            child: Container(
              width: double.infinity,
              height: 48.rh(context),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 4),
                  CustomText(
                    _isFileSelected
                        ? 'changeFile'.translate(context)
                        : 'addFile'.translate(context),
                    color: context.color.textLightColor,
                    fontSize: context.font.md,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_pickedFilePath != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomText(
                  'File Name: ${_pickedFilePath!.split('/').last}',
                  color: context.color.textColorDark,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
