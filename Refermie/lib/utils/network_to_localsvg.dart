import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

class NetworkToLocalSvg {
  final Dio dio = Dio();

  Future<String?> convert(String url) async {
    try {
      final response = await dio.get<dynamic>(url);

      if (response.statusCode == 200) {
        return response.data?.toString() ?? '';
      } else {
        log('Error while load svg');
      }
    } on Exception catch (_) {
      rethrow;
    }
    return null;
  }

  Widget svg(String url, {Color? color, double? width, double? height}) {
    // return SizedBox.shrink();
    if (Hive.box<dynamic>(HiveKeys.svgBox).containsKey(url) &&
        Hive.box<dynamic>(HiveKeys.svgBox).get(url).toString().isNotEmpty) {
      return SvgPicture.string(
        Hive.box<dynamic>(HiveKeys.svgBox).get(url)?.toString() ?? '',
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, .srcIn),
        width: width,
        height: height,
      );
    } else {
      return FutureBuilder<String?>(
        future: convert(url),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (Hive.box<dynamic>(HiveKeys.svgBox).containsKey(url)) {
            if (Hive.box<dynamic>(HiveKeys.svgBox).get(url) == null) {
              unawaited(
                Hive.box<dynamic>(HiveKeys.svgBox).put(url, snapshot.data),
              );
              return SvgPicture.string(
                snapshot.data ?? '',
                colorFilter: color == null
                    ? null
                    : ColorFilter.mode(color, .srcIn),
                width: width,
                height: height,
              );
            } else {
              return SvgPicture.string(
                Hive.box<dynamic>(HiveKeys.svgBox).get(url)?.toString() ?? '',
                colorFilter: color == null
                    ? null
                    : ColorFilter.mode(color, .srcIn),
                width: width,
                height: height,
              );
            }
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              unawaited(
                Hive.box<dynamic>(HiveKeys.svgBox).put(url, snapshot.data),
              );
              return SvgPicture.string(
                snapshot.data ?? '',
                colorFilter: color == null
                    ? null
                    : ColorFilter.mode(color, .srcIn),
                width: width,
                height: height,
              );
            } else {
              return Container();
            }
          }
        },
      );
    }
  }
}

class _SVGBUILDER extends StatefulWidget {
  const _SVGBUILDER();

  @override
  State<_SVGBUILDER> createState() => _SVGBUILDERState();
}

class _SVGBUILDERState extends State<_SVGBUILDER> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
