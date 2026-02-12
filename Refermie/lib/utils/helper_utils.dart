import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/data/model/ad_banner_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/locale_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

enum MessageType {
  success(successMessageColor),
  warning(warningMessageColor),
  error(errorMessageColor)
  ;

  const MessageType(this.value);

  final Color value;
}

class HelperUtils {
  static Future<bool> checkInternet() async {
    var check = false;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      check = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      check = true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      check = true;
    }
    return check;
  }

  static Future<bool> hasStoragePermissionGiven() async {
    if (Platform.isIOS) {
      var permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.storage.request()).isGranted;
      }
      return permissionGiven;
    }
    //if it is for android
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    if (androidDeviceInfo.version.sdkInt < 33) {
      var permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.storage.request()).isGranted;
      }
      return permissionGiven;
    } else {
      var permissionGiven = await Permission.photos.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.photos.request()).isGranted;
      }
      return permissionGiven;
    }
  }

  static String checkHost(String url) {
    if (url.endsWith('/')) {
      return url;
    } else {
      return '$url/';
    }
  }

  static Map<dynamic, Type> runtimeValueLog(Map<dynamic, dynamic> map) {
    return map.map((key, value) => MapEntry(key, value.runtimeType));
  }

  static Future<String?> getDownloadPath({
    dynamic Function(dynamic err)? onError,
  }) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }
    } on Exception catch (err) {
      onError?.call(err);
    }
    return directory?.path;
  }

  static Future<void> printServerError(
    String url, {
    required int statusCode,
    required Map<dynamic, dynamic> parameter,
    required String response,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log($statusCode).html')
      ..writeAsStringSync('''
          $url,<br><br>
          $parameter,<br></br>
          Response: <br></br>
          $response
          ''');

    if (statusCode == 500) {
      await OpenFilex.open(file.path);
    }
  }

  static Future<void> onTapBanner(
    BuildContext context,
    AdBanner? banner,
  ) async {
    if (banner == null) return;
    if (banner.type == 'external_link') {
      await url_launcher.launchUrl(Uri.parse(banner.externalLinkUrl ?? ''));
    } else if (banner.type == 'banner_only') {
      await UiUtils.showFullScreenImage(
        context,
        provider: NetworkImage(banner.image ?? ''),
      );
    } else if (banner.type == 'property') {
      try {
        unawaited(Widgets.showLoader(context));
        final fetch = PropertyRepository();
        final dataOutput = await fetch.fetchPropertyFromPropertyId(
          id: banner.propertyId ?? 0,
          isMyProperty:
              banner.property?.addedBy.toString() == HiveUtils.getUserId(),
        );

        Widgets.hideLoder(context);

        await HelperUtils.goToNextPage(
          Routes.propertyDetails,
          context,
          false,
          args: {'propertyData': dataOutput},
        );
      } on Exception catch (_) {
        Widgets.hideLoder(context);
      }
    }
  }

  static int comparableVersion(String version) {
    //removing dot from version and parsing it into int
    final plain = version.replaceAll('.', '');

    return int.parse(plain);
  }

  static String nativeDeepLinkUrlOfProperty(String slug) {
    return 'https://${AppSettings.shareNavigationWebUrl}/property-details/$slug?share=true&lang=${HiveUtils.getLanguageCode()}';
  }

  static String nativeDeepLinkUrlOfProject(String slug) {
    return 'https://${AppSettings.shareNavigationWebUrl}/project-details/$slug?share=true&lang=${HiveUtils.getLanguageCode()}';
  }

  static String nativeDeepLinkUrlOfAgent(String slug) {
    return 'https://${AppSettings.shareNavigationWebUrl}/agent-details/$slug?share=true&lang=${HiveUtils.getLanguageCode()}';
  }

  static String nativeDeepLinkUrlOfArticle(String slug) {
    return 'https://${AppSettings.shareNavigationWebUrl}/article-details/$slug?share=true&lang=${HiveUtils.getLanguageCode()}';
  }

  static Future<void> share(
    BuildContext context,
    String slugId,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: context.color.textColorDark),
              title: CustomText('copylink'.translate(context)),
              onTap: () async {
                var deepLink = '';
                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfProperty(slugId);
                }

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                    context,
                    'copied',
                  );
                });
              },
            ),
            ListTile(
              leading: CustomImage(
                imageUrl: AppIcons.shareIcon,
                height: 24.rh(context),
                width: 24.rw(context),
                fit: .fill,
                color: context.color.textColorDark,
              ),
              title: CustomText('share'.translate(context)),
              onTap: () async {
                var deepLink = '';

                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfProperty(slugId);
                }

                final text =
                    '${'sharePropertyDescription'.translate(context)}\n$deepLink';
                await SharePlus.instance.share(
                  ShareParams(
                    text: text,
                    subject: 'shareProperty'.translate(context),
                    sharePositionOrigin: sharePositionOrigin,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> shareProject(
    BuildContext context,
    String slugId,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: context.color.textColorDark),
              title: CustomText('copylink'.translate(context)),
              onTap: () async {
                var deepLink = '';
                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfProject(slugId);
                }

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                    context,
                    'copied',
                  );
                });
              },
            ),
            ListTile(
              leading: CustomImage(
                imageUrl: AppIcons.shareIcon,
                height: 24.rh(context),
                width: 24.rw(context),
                fit: .fill,
                color: context.color.textColorDark,
              ),
              title: CustomText('share'.translate(context)),
              onTap: () async {
                var deepLink = '';

                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfProject(slugId);
                }

                final text =
                    '${'shareProjectDescription'.translate(context)}\n$deepLink';
                await SharePlus.instance.share(
                  ShareParams(
                    text: text,
                    subject: 'shareProject'.translate(context),
                    sharePositionOrigin: sharePositionOrigin,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> shareAgent(
    BuildContext context,
    String slugId,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: context.color.textColorDark),
              title: CustomText('copylink'.translate(context)),
              onTap: () async {
                var deepLink = '';
                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfAgent(slugId);
                }

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                    context,
                    'copied',
                  );
                });
              },
            ),
            ListTile(
              leading: CustomImage(
                imageUrl: AppIcons.shareIcon,
                height: 24.rh(context),
                width: 24.rw(context),
                fit: .fill,
                color: context.color.textColorDark,
              ),
              title: CustomText('share'.translate(context)),
              onTap: () async {
                var deepLink = '';

                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfAgent(slugId);
                }

                final text =
                    '${'shareAgentDescription'.translate(context)}\n$deepLink';
                await SharePlus.instance.share(
                  ShareParams(
                    text: text,
                    subject: 'shareAgent'.translate(context),
                    sharePositionOrigin: sharePositionOrigin,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> shareArticle(
    BuildContext context,
    String slugId,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: context.color.textColorDark),
              title: CustomText('copylink'.translate(context)),
              onTap: () async {
                var deepLink = '';
                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfArticle(slugId);
                }

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                    context,
                    'copied',
                  );
                });
              },
            ),
            ListTile(
              leading: CustomImage(
                imageUrl: AppIcons.shareIcon,
                height: 24.rh(context),
                width: 24.rw(context),
                fit: .fill,
                color: context.color.textColorDark,
              ),
              title: CustomText('share'.translate(context)),
              onTap: () async {
                var deepLink = '';

                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfArticle(slugId);
                }

                final text =
                    '${'shareArticleDescription'.translate(context)}\n$deepLink';
                await SharePlus.instance.share(
                  ShareParams(
                    text: text,
                    subject: 'shareArticle'.translate(context),
                    sharePositionOrigin: sharePositionOrigin,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static bool checkIsUserInfoFilled({String name = '', String email = ''}) {
    final chkname = name;
    if (name.trim().isEmpty) {
      // chkname = Constant.session.getStringData(Session.keyUserName);
    }
    return chkname.trim().isNotEmpty;
  }

  static String mobileNumberWithoutCountryCode() {
    final mobile = HiveUtils.getUserDetails().mobile;

    final countryCode = HiveUtils.getCountryCode()?.toString();

    final countryCodeLength = countryCode?.length ?? 0;

    final mobileNumber = mobile!.substring(countryCodeLength, mobile.length);

    return mobileNumber;
  }

  static String formatPhoneNumber(String number, String phoneCode) {
    // Remove any existing formatting
    final cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');
    final phoneCodeWithPlus = '+$phoneCode';

    if (cleanNumber.isEmpty) return number;

    switch (phoneCodeWithPlus) {
      case '+91': // India: XXXXX XXXXX
        if (cleanNumber.length != 10) return number;
        return '${cleanNumber.substring(0, 5)} ${cleanNumber.substring(5)}';

      case '+1': // USA/Canada: (XXX) XXX-XXXX
        if (cleanNumber.length != 10) return number;
        return '(${cleanNumber.substring(0, 3)}) ${cleanNumber.substring(3, 6)}-${cleanNumber.substring(6)}';

      case '+44': // UK: XXXX XXX XXX
        if (cleanNumber.length != 10) return number;
        return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4, 7)} ${cleanNumber.substring(7)}';

      case '+61': // Australia: XXX XXX XXX
        if (cleanNumber.length != 9) return number;
        return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6)}';

      case '+33': // France: X XX XX XX XX
        if (cleanNumber.length != 9) return number;
        return '${cleanNumber.substring(0, 1)} ${cleanNumber.substring(1, 3)} ${cleanNumber.substring(3, 5)} ${cleanNumber.substring(5, 7)} ${cleanNumber.substring(7)}';

      case '+49': // Germany: XXX XXXXXXX
        if (cleanNumber.length < 10 || cleanNumber.length > 11) return number;
        return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3)}';

      case '+55': // Brazil: (XX) XXXXX-XXXX
        if (cleanNumber.length != 11) return number;
        return '(${cleanNumber.substring(0, 2)}) ${cleanNumber.substring(2, 7)}-${cleanNumber.substring(7)}';

      case '+81': // Japan: XX-XXXX-XXXX
        if (cleanNumber.length != 10) return number;
        return '${cleanNumber.substring(0, 2)}-${cleanNumber.substring(2, 6)}-${cleanNumber.substring(6)}';

      case '+86': // China: XXX XXXX XXXX
        if (cleanNumber.length != 11) return number;
        return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 7)} ${cleanNumber.substring(7)}';

      case '+971': // UAE: XX XXX XXXX
        if (cleanNumber.length != 9) return number;
        return '${cleanNumber.substring(0, 2)} ${cleanNumber.substring(2, 5)} ${cleanNumber.substring(5)}';

      case '+966': // Saudi Arabia: XX XXX XXXX
        if (cleanNumber.length != 9) return number;
        return '${cleanNumber.substring(0, 2)} ${cleanNumber.substring(2, 5)} ${cleanNumber.substring(5)}';

      default:
        // Generic formatting for unsupported codes
        if (cleanNumber.length <= 4) return cleanNumber;
        if (cleanNumber.length <= 7) {
          return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3)}';
        }
        return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6)}';
    }
  }

  static int getMaxPhoneLength(String phoneCode) {
    final phoneCodeWithPlus = '+$phoneCode';
    switch (phoneCodeWithPlus) {
      case '+1': // USA/Canada
      case '+44': // UK
      case '+91': // India
        return 10;
      case '+81': // Japan
        return 10;
      case '+86': // China
      case '+55': // Brazil
        return 11;

      case '+61': // Australia
      case '+33': // France
      case '+971': // UAE
      case '+966': // Saudi Arabia
        return 9;

      case '+49': // Germany (can be 10 or 11)
        return 11;

      case '+7': // Russia
        return 10;

      case '+52': // Mexico
        return 10;

      case '+34': // Spain
        return 9;

      case '+39': // Italy
        return 10;

      case '+82': // South Korea
        return 10;

      case '+65': // Singapore
        return 8;

      case '+60': // Malaysia
        return 10;

      case '+62': // Indonesia
        return 11;

      case '+63': // Philippines
        return 10;

      case '+66': // Thailand
        return 9;

      case '+84': // Vietnam
        return 10;

      case '+880': // Bangladesh
        return 10;

      case '+92': // Pakistan
        return 10;

      case '+94': // Sri Lanka
        return 9;

      case '+977': // Nepal
        return 10;

      case '+27': // South Africa
        return 9;

      case '+234': // Nigeria
        return 10;

      case '+254': // Kenya
        return 9;

      default:
        return 15; // Max international phone number length
    }
  }

  static void showSnackBarMessage(
    BuildContext? context,
    String message, {
    int messageDuration = 3,
    MessageType? type,
    bool? isFloating,
    EdgeInsets? margin,
    TextAlign? textAlign,
  }) {
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(
          message.translate(context),
          maxLines: 3,
          textAlign: textAlign,
          color: context.color.buttonColor,
        ),
        behavior: (isFloating ?? false) ? .floating : null,
        backgroundColor: type?.value ?? successMessageColor,
        duration: Duration(seconds: messageDuration),
        margin: isFloating ?? false ? margin ?? EdgeInsets.zero : null,
      ),
    );
  }

  static Future<dynamic> sendApiRequest(
    String url,
    Map<String, dynamic> body,
    dynamic isPost,
    BuildContext context, {
    bool passUserid = true,
  }) async {
    final headersData = <String, String>{'accept': 'application/json'};

    final token = HiveUtils.getJWT().toString();
    if (token.trim().isNotEmpty) {
      headersData['Authorization'] = 'Bearer $token';
    }
    if (passUserid && HiveUtils.isUserAuthenticated()) {
      // body[Api.userid] = HiveUtils.getUserId().toString();
    }
    Response response;
    try {
      if (isPost as bool) {
        response = await post(
          Uri.parse(Constant.baseUrl + url),
          body: body.isNotEmpty ? body : null,
          headers: headersData,
        );
      } else {
        response = await get(
          Uri.parse(Constant.baseUrl + url),
          headers: headersData,
        );
      }
      await Future.delayed(Duration.zero, () {
        return getJsonResponse(context, response: response);
      });
    } on SocketException {
      throw FetchDataException('noInternetErrorMsg'.translate(context));
    } on TimeoutException {
      throw FetchDataException('nodatafound'.translate(context));
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> getJsonResponse(
    BuildContext context, {
    bool isfromfile = false,
    StreamedResponse? streamedResponse,
    Response? response,
  }) async {
    int code;
    if (isfromfile) {
      code = streamedResponse!.statusCode;
    } else {
      code = response!.statusCode;
    }
    switch (code) {
      case 200:
        if (isfromfile) {
          final responseData = await streamedResponse!.stream.toBytes();
          return String.fromCharCodes(responseData);
        } else {
          return response!.body;
        }

      case 400:
        throw BadRequestException(response!.body);
      case 401:
        /* Constant.isUserDeactivated = true;
        print("isDeactivated ? -- ${Constant.isUserDeactivated}");
        break; */

        Map<dynamic, dynamic> getdata;
        getdata = {};
        if (isfromfile) {
          final responseData = await streamedResponse!.stream.toBytes();
          getdata = json.decode(String.fromCharCodes(responseData)) as Map;
        } else {
          getdata = json.decode(response!.body) as Map;
        }

        Future.delayed(Duration.zero, () {
          showSnackBarMessage(context, getdata[Api.message]?.toString() ?? '');
        });
        throw UnauthorisedException(getdata[Api.message]?.toString() ?? '');
      case 403:
        throw UnauthorisedException(response!.body);
      case 500:
      default:
        throw FetchDataException(
          'Error occurred while Communication with Server with StatusCode: $code',
        );
    }
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ['b', 'kb', 'mb', 'gb', 'tb'];
    if (bytes == 0) return '0${suffixes[0]}';
    final i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static Future<void> killPreviousPages(
    BuildContext context,
    String nextPage,
    Object args,
  ) async {
    await Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(nextPage, (route) => false, arguments: args);
  }

  static Future<void> goToNextPage(
    String nextPage,
    BuildContext bContext,
    dynamic isReplace, {
    Object? args,
  }) async {
    if (isReplace as bool) {
      await Navigator.of(
        bContext,
      ).pushReplacementNamed(nextPage, arguments: args);
    } else {
      await Navigator.of(bContext).pushNamed(nextPage, arguments: args);
    }
  }

  static String setFirstLetterUppercase(String value) {
    if (value.isNotEmpty) value.replaceAll('_', ' ');
    return value.toTitleCase();
  }

  static Widget checkVideoType(
    String url, {
    required Widget Function() onYoutubeVideo,
    required Widget Function() onOtherVideo,
  }) {
    final youtubeDomains = ['youtu.be', 'youtube.com'];

    final uri = Uri.parse(url);
    final host = uri.host.replaceAll('www.', '');
    if (youtubeDomains.contains(host)) {
      return onYoutubeVideo.call();
    } else {
      return onOtherVideo.call();
    }
  }

  static CountryService countryCodeService = CountryService();

  /// it will return user's locale-based country code
  static Future<Country> getSimCountry() async {
    final countryList = countryCodeService.getAll();

    var simCountry = countryList.firstWhere(
      (element) {
        return element.phoneCode == HiveUtils.getCountryCode();
      },
      orElse: () {
        return countryList
            .where(
              (element) => element.phoneCode == Constant.defaultCountryCode,
            )
            .first;
      },
    );

    if (Constant.isDemoModeOn) {
      simCountry = countryList
          .where((element) => element.phoneCode == Constant.demoCountryCode)
          .first;
    }

    return simCountry;
  }

  static bool isYoutubeVideo(String url) {
    final youtubeDomains = ['youtu.be', 'youtube.com'];

    final uri = Uri.parse(url);
    final host = uri.host.replaceAll('www.', '');
    if (youtubeDomains.contains(host)) {
      return true;
    } else {
      return false;
    }
  }

  static bool isValidLocale(String locale) {
    return localeList.contains(locale);
  }

  static Future<File?> compressImageFile(File file) async {
    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        "${file.path}_compressed.${file.path.split('.').last}",
        quality: Constant.uploadImageQuality,
      );
      return File(compressedFile?.path ?? '');
    } on Exception catch (_) {
      return null; //If any error occurs during compression, the process is stopped.
    }
  }
}

///Post Frame Callback
void postFrame(void Function(Duration t) fn) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    fn.call(timeStamp);
  });
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((str) => str.toCapitalized()).join(' ');
}

extension ListExtensions<T> on List<T> {
  Future<List<R>> parallelMap<R>(
    FutureOr<R> Function(T) mapper, {
    int concurrency = 1,
  }) async {
    final results = <R>[];
    final queue = StreamController<T>.broadcast();
    final done = Completer<dynamic>();

    // Start worker functions
    for (var i = 0; i < concurrency; i++) {
      _startWorker(queue.stream, results, mapper, done);
    }

    // Add elements to the queue
    forEach(queue.add);
    await queue.close();

    // Wait for all workers to finish
    await done.future;

    return results;
  }

  void _startWorker<J, R>(
    Stream<J> input,
    List<R> results,
    FutureOr<R> Function(J) mapper,
    Completer<dynamic> done,
  ) {
    input.listen(
      (element) async {
        final result = await mapper(element);
        results.add(result);
      },
      onDone: () {
        if (!done.isCompleted && results.length == length) {
          done.complete();
        }
      },
    );
  }
}
