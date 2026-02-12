import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImage {
  final ImagePicker _picker = ImagePicker();
  final StreamController<dynamic> _imageStreamController =
      StreamController.broadcast();
  Stream<dynamic> get imageStream => _imageStreamController.stream;
  StreamSink<dynamic> get _sink => _imageStreamController.sink;
  StreamSubscription<dynamic>? subscription;
  File? pickedFile;
  File? pickedPreviousFile;

  Future<void> pick({ImageSource? source, bool? pickMultiple}) async {
    pickedPreviousFile = pickedFile;

    if (pickMultiple == false || pickMultiple == null) {
      await _picker
          .pickImage(
            source: source ?? ImageSource.gallery,
          )
          .then((XFile? pickedFile) async {
            var file = File(pickedFile!.path);

            const threeMB = 3000000;
            if (await file.length() >= threeMB) {
              final file2 = await HelperUtils.compressImageFile(file);
              file = file2!;
            }
            pickedFile = XFile(file.path);
            //adding map to stream
            _sink.add({
              'error': '',
              'file': file,
            });
          })
          .catchError((dynamic error) {
            _sink.add({
              'error': error,
              'file': null,
            });
          });
    } else {
      final list = await _picker.pickMultiImage(
        imageQuality: Constant.uploadImageQuality,
      );
      const threeMB = 3000000;

      final result = list.map((image) async {
        File myImage;
        final length = await image.length();
        if (length >= threeMB) {
          final file2 = await HelperUtils.compressImageFile(File(image.path));
          myImage = file2!;
          // var i = await myImage.length();
        } else {
          myImage = File(image.path);
        }
        return myImage;
      });
      final templistFile = <dynamic>[];
      await for (final Future<File> futureFile in Stream.fromIterable(result)) {
        final file = await futureFile;
        templistFile.add(file);
      }

      _sink.add({
        'error': '',
        'file': templistFile,
      });
    }
  }

  /// This widget will listen changes in ui, it is wrapper around Stream builder
  Widget listenChangesInUI(
    dynamic Function(
      BuildContext context,
      dynamic image,
    )
    ondata,
  ) {
    return StreamBuilder(
      stream: imageStream,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data['file'] is File) {
            pickedFile = snapshot.data['file'] as File?;
          }

          return ondata.call(
                context,
                snapshot.data['file'],
              )
              as Widget;
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ondata.call(
                context,
                null,
              )
              as Widget;
        }
        return ondata.call(
              context,
              null,
            )
            as Widget;
      },
    );
  }

  void listener(void Function(dynamic)? onData) {
    subscription = imageStream.listen((data) {
      log('SUBSCRIPTION ${subscription?.isPaused}');
      if (subscription?.isPaused == false) {
        log('CALLING INSIDE');
        onData?.call(data['file']);
      }
    });
  }

  void pauseSubscription() {
    subscription?.pause();
  }

  void resumeSubscription() {
    subscription?.resume();
  }

  void clearImage() {
    pickedFile = null;
    _sink.add(null);
  }

  void dispose() {
    if (!_imageStreamController.isClosed) {
      unawaited(_imageStreamController.close());
    }
  }
}

enum PickImageStatus { initial, waiting, done, error }
