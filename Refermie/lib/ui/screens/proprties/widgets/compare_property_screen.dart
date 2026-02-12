import 'package:ebroker/data/model/compare_property_model.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/home/widgets/property_card_big.dart';
import 'package:ebroker/utils/custom_appbar.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComparePropertyScreen extends StatefulWidget {
  const ComparePropertyScreen({
    required this.comparisionData,
    required this.category,
    required this.isSourcePremium,
    required this.isTargetPremium,
    required this.isSourcePromoted,
    required this.isTargetPromoted,
    super.key,
  });

  final ComparePropertyModel comparisionData;
  final Categorys category;
  final bool isSourcePremium;
  final bool isTargetPremium;
  final bool isSourcePromoted;
  final bool isTargetPromoted;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => ComparePropertyScreen(
        comparisionData: arguments?['comparisionData'] as ComparePropertyModel,
        isSourcePremium: arguments?['isSourcePremium'] as bool,
        isTargetPremium: arguments?['isTargetPremium'] as bool,
        isSourcePromoted: arguments?['isSourcePromoted'] as bool,
        isTargetPromoted: arguments?['isTargetPromoted'] as bool,
        category: arguments?['category'] as Categorys,
      ),
    );
  }

  @override
  ComparePropertyScreenState createState() => ComparePropertyScreenState();
}

class ComparePropertyScreenState extends State<ComparePropertyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'comparedProperties'.translate(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          mainAxisSize: .min,
          children: [
            // Property cards row
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: _buildPropertyCard(
                      title:
                          widget
                              .comparisionData
                              .sourceProperty
                              ?.translatedTitle ??
                          widget.comparisionData.sourceProperty?.title ??
                          '',
                      image:
                          widget.comparisionData.sourceProperty?.titleImage ??
                          '',
                      price: widget.comparisionData.sourceProperty?.price ?? '',
                      city: widget.comparisionData.sourceProperty?.city ?? '',
                      propertyType:
                          widget.comparisionData.sourceProperty?.propertyType ??
                          '',
                      categoryName:
                          widget
                              .comparisionData
                              .sourceProperty
                              ?.category
                              ?.translatedName ??
                          widget
                              .comparisionData
                              .sourceProperty
                              ?.category
                              ?.name ??
                          '',
                      categoryIcon:
                          widget
                              .comparisionData
                              .sourceProperty
                              ?.category
                              ?.image ??
                          '',
                      isPremium: widget.isSourcePremium,
                      isPromoted: widget.isSourcePromoted,
                      rentDuration:
                          widget.comparisionData.sourceProperty?.rentduration
                              ?.translate(context) ??
                          '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPropertyCard(
                      title:
                          widget
                              .comparisionData
                              .targetProperty
                              ?.translatedTitle ??
                          widget.comparisionData.targetProperty?.title ??
                          '',
                      image:
                          widget.comparisionData.targetProperty?.titleImage ??
                          '',
                      price: widget.comparisionData.targetProperty?.price ?? '',
                      city: widget.comparisionData.targetProperty?.city ?? '',
                      propertyType:
                          widget.comparisionData.targetProperty?.propertyType ??
                          '',
                      categoryName:
                          widget
                              .comparisionData
                              .targetProperty
                              ?.category
                              ?.translatedName ??
                          widget
                              .comparisionData
                              .targetProperty
                              ?.category
                              ?.name ??
                          '',
                      categoryIcon:
                          widget
                              .comparisionData
                              .targetProperty
                              ?.category
                              ?.image ??
                          '',
                      isPremium: widget.isTargetPremium,
                      isPromoted: widget.isTargetPromoted,
                      rentDuration:
                          widget.comparisionData.targetProperty?.rentduration
                              ?.translate(context) ??
                          '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Table with custom-colored rows
            _buildComparisonTable(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context) {
    final rows = _buildComparisonRows(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.color.borderColor),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: context.color.textColorDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 4),
                    child: CustomText(
                      'details'.translate(context),
                      fontWeight: .bold,
                      color: context.color.secondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: CustomText(
                    widget.comparisionData.sourceProperty?.translatedTitle ??
                        widget.comparisionData.sourceProperty?.title ??
                        '',
                    maxLines: 1,
                    fontWeight: .bold,
                    color: context.color.secondaryColor,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: CustomText(
                    widget.comparisionData.targetProperty?.translatedTitle ??
                        widget.comparisionData.targetProperty?.title ??
                        '',
                    maxLines: 1,
                    fontWeight: .bold,
                    color: context.color.secondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Content rows with alternating colors
          ...List.generate(rows.length, (index) {
            final isEven = index.isEven;
            final rowData = rows[index];

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isEven
                    ? context.color.secondaryColor
                    : Color.lerp(
                        context.color.secondaryColor,
                        context.color.textColorDark,
                        0.1,
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CustomText(
                        rowData['title'] ?? '',
                        fontWeight: .bold,
                        fontSize: context.font.xs,
                        color: context.color.textColorDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: CustomText(
                      rowData['source'] ?? '',
                      fontSize: context.font.xs,
                      color: context.color.textColorDark,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: CustomText(
                      rowData['target'] ?? '',
                      fontSize: context.font.xs,
                      color: context.color.textColorDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, String>> _buildComparisonRows(BuildContext context) {
    final sourceProperty = widget.comparisionData.sourceProperty;
    final targetProperty = widget.comparisionData.targetProperty;

    // Basic property details comparison
    final rows = <Map<String, String>>[
      {
        'title': 'location'.translate(context),
        'source':
            '${sourceProperty?.city ?? ''}, ${sourceProperty?.state ?? ''}, ${sourceProperty?.country ?? ''}',
        'target':
            '${targetProperty?.city ?? ''}, ${targetProperty?.state ?? ''}, ${targetProperty?.country ?? ''}',
      },
      {
        'title': 'propertyType'.translate(context),
        'source':
            sourceProperty?.propertyType?.toLowerCase().translate(context) ??
            '',
        'target':
            targetProperty?.propertyType?.toLowerCase().translate(context) ??
            '',
      },
      if (sourceProperty?.createdAt != '' ||
          targetProperty?.createdAt != '') ...[
        {
          'title': 'createdDate'.translate(context),
          'source': sourceProperty?.createdAt ?? '',
          'target': targetProperty?.createdAt ?? '',
        },
      ],
      {
        'title': 'totalLikes'.translate(context),
        'source': sourceProperty?.totalLikes?.toString() ?? '0',
        'target': targetProperty?.totalLikes?.toString() ?? '0',
      },
      {
        'title': 'totalViews'.translate(context),
        'source': sourceProperty?.totalViews?.toString() ?? '0',
        'target': targetProperty?.totalViews?.toString() ?? '0',
      },
    ];

    // Add facilities comparison
    final allFacilityIds = <int>{};

    // Collect all unique facility IDs from both properties
    sourceProperty?.facilities?.forEach((facility) {
      if (facility.id != null) allFacilityIds.add(facility.id!);
    });

    targetProperty?.facilities?.forEach((facility) {
      if (facility.id != null) allFacilityIds.add(facility.id!);
    });

    // Add facility rows
    for (final facilityId in allFacilityIds) {
      final sourceFacility = sourceProperty?.facilities?.firstWhere(
        (f) => f.id == facilityId,
        orElse: Facilities.new,
      );

      final targetFacility = targetProperty?.facilities?.firstWhere(
        (f) => f.id == facilityId,
        orElse: Facilities.new,
      );

      if (sourceFacility?.name != null || targetFacility?.name != null) {
        // Format the source value
        final sourceValue = _formatFacilityValue(
          sourceFacility?.value,
          sourceFacility,
        );

        // Format the target value
        final targetValue = _formatFacilityValue(
          targetFacility?.value,
          targetFacility,
        );

        rows.add({
          'title':
              (sourceFacility?.translatedName ?? sourceFacility?.name) ??
              (targetFacility?.translatedName ?? targetFacility?.name) ??
              '',
          'source': sourceValue,
          'target': targetValue,
        });
      }
    }

    // Add nearby places comparison
    final allNearbyPlaceIds = <int>{};

    // Collect all unique nearby place IDs
    sourceProperty?.nearByPlaces?.forEach((place) {
      if (place.id != null) allNearbyPlaceIds.add(place.id!);
    });

    targetProperty?.nearByPlaces?.forEach((place) {
      if (place.id != null) allNearbyPlaceIds.add(place.id!);
    });

    // Add nearby place rows
    for (final placeId in allNearbyPlaceIds) {
      final sourcePlace = sourceProperty?.nearByPlaces?.firstWhere(
        (p) => p.id == placeId,
        orElse: NearByPlaces.new,
      );

      final targetPlace = targetProperty?.nearByPlaces?.firstWhere(
        (p) => p.id == placeId,
        orElse: NearByPlaces.new,
      );

      if (sourcePlace?.name != null || targetPlace?.name != null) {
        rows.add({
          'title':
              (sourcePlace?.translatedName ?? sourcePlace?.name) ??
              (targetPlace?.translatedName ?? targetPlace?.name) ??
              '',
          'source': sourcePlace?.distance != null
              ? '${sourcePlace!.distance} ${AppSettings.distanceOption.translate(context)}'
              : 'N/A',
          'target': targetPlace?.distance != null
              ? '${targetPlace!.distance} ${AppSettings.distanceOption.translate(context)}'
              : 'N/A',
        });
      }
    }

    return rows;
  }

  String _formatFacilityValue(dynamic value, Facilities? facility) {
    if (value == null) return 'N/A';

    if (value is String) {
      // Try to find translated value for dropdown/radiobutton options
      final translatedValue = _getTranslatedValue(value, facility);
      return translatedValue ?? value;
    } else if (value is List) {
      // Handle array values (for checkbox with multiple selections)
      final translatedValues = <String>[];
      for (final item in value) {
        final translatedItem = _getTranslatedValue(item.toString(), facility);
        translatedValues.add(translatedItem ?? item.toString());
      }
      return translatedValues.join(', ');
    } else {
      // Fallback for any other type
      return value.toString();
    }
  }

  String? _getTranslatedValue(String originalValue, Facilities? facility) {
    if (facility?.translatedOptionValue == null) return null;

    // Find the translated value for the original value
    final translatedOption = facility!.translatedOptionValue!.firstWhere(
      (option) => option.value == originalValue,
      orElse: () => TranslatedOptionValue(
        value: originalValue,
        translated: originalValue,
      ),
    );

    // Return translated value if it exists and is different from original
    return translatedOption.translated?.isNotEmpty ?? false
        ? translatedOption.translated
        : null;
  }

  Widget _buildPropertyCard({
    required String title,
    required String image,
    required String price,
    required String city,
    required String propertyType,
    required String categoryName,
    required String categoryIcon,
    required bool isPremium,
    required bool isPromoted,
    required String rentDuration,
  }) {
    return PropertyCardBig(
      property: PropertyModel(
        title: title,
        titleImage: image,
        price: price,
        city: city,
        propertyType: propertyType,
        category: Categorys(
          category: categoryName,
          image: categoryIcon,
        ),
        promoted: isPromoted,
        isPremium: isPremium,
        rentduration: rentDuration,
      ),
      disableTap: true,
      showLikeButton: false,
      isFromCompare: false,
    );
  }
}
