import 'package:dotted_border/dotted_border.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DocumentUpload extends StatefulWidget {
  const DocumentUpload({
    required this.onDocumentSelected,
    super.key,
  });
  final dynamic Function(BankRecipt?) onDocumentSelected;

  @override
  DocumentUploadState createState() => DocumentUploadState();
}

class DocumentUploadState extends State<DocumentUpload> {
  BankRecipt? selectedDocument;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          if (selectedDocument == null) ...[
            buildDocumentsPicker(context),
          ],
          if (selectedDocument != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Flexible(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: CustomText(
                      selectedDocument!.name,
                      fontWeight: .w600,
                      fontSize: 14,
                      color: context.color.textColorDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDocument = null;
                    });
                    widget.onDocumentSelected(selectedDocument);
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.close,
                      color: context.color.inverseSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildDocumentsPicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDocument(context),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: context.color.textLightColor,
          radius: const Radius.circular(10),
        ),
        child: Container(
          width: context.screenWidth,
          height: 45.rh(context),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: .center,
            children: [
              CustomImage(
                imageUrl: AppIcons.plusButtonIcon,
                color: context.color.textColorDark.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              CustomText('uploadBankReceipt'.translate(context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpeg', 'png', 'jpg', 'pdf', 'doc', 'docx', 'webp'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.name.split('.').last.toLowerCase() != 'jpeg' &&
            file.name.split('.').last.toLowerCase() != 'png' &&
            file.name.split('.').last.toLowerCase() != 'jpg' &&
            file.name.split('.').last.toLowerCase() != 'pdf' &&
            file.name.split('.').last.toLowerCase() != 'doc' &&
            file.name.split('.').last.toLowerCase() != 'docx' &&
            file.name.split('.').last.toLowerCase() != 'webp') {
          await Fluttertoast.showToast(
            msg: 'pleaseSelectAValidDocument',
          );
          return;
        }
        setState(() {
          selectedDocument = BankRecipt(
            name: file.name,
            file: file.path,
          );
        });
        widget.onDocumentSelected(selectedDocument);
      }
    } on Exception catch (e) {
      await Fluttertoast.showToast(msg: e.toString());
    }
  }
}

class BankRecipt {
  BankRecipt({
    required this.name,
    this.file,
    this.id,
  });
  final String name;
  final String? file;
  final int? id;
}
