import 'package:ebroker/data/repositories/map.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class PropertyMapScreen extends StatefulWidget {
  const PropertyMapScreen({super.key});

  static Route<dynamic> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) {
        return const PropertyMapScreen();
      },
    );
  }

  @override
  State<PropertyMapScreen> createState() => _PropertyMapScreenState();
}

class _PropertyMapScreenState extends State<PropertyMapScreen> {
  late String _darkMapStyle;
  final TextEditingController _searchController = TextEditingController();
  String previouseSearchQuery = '';
  LatLng? citylatLong;
  Timer? _timer;
  Set<Marker> marker = {};
  Map<dynamic, dynamic> map = {};
  GoogleMapController? _googleMapController;
  Completer<GoogleMapController> completer = Completer();
  bool isMapCreated = false;
  final FocusNode _searchFocus = FocusNode();
  List<GooglePlaceModel>? cities;
  int selectedMarker = 999999999999999;
  int? propertyId;
  ValueNotifier<bool> isLoadingProperty = ValueNotifier<bool>(false);
  PropertyModel? activePropertyModal;
  List<PropertyModel>? activePropertiesList;
  ValueNotifier<bool> loadintCitiesInProgress = ValueNotifier<bool>(false);
  bool showSellRentLables = false;
  bool showGoogleMap = true;
  late BitmapDescriptor customIconSell;
  late BitmapDescriptor customIconRent;
  late BitmapDescriptor customIconSelected;
  double iconWidth = 24;
  double iconHeight = 32;
  Future<void> _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString(
      'assets/map_styles/dark_map.json',
    );
  }

  Future<void> searchDelayTimer() async {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (_searchController.text.isNotEmpty) {
          if (previouseSearchQuery != _searchController.text) {
            try {
              loadintCitiesInProgress.value = true;
              cities = await GooglePlaceRepository().serchCities(
                _searchController.text,
              );
              loadintCitiesInProgress.value = false;
            } on Exception catch (_) {
              loadintCitiesInProgress.value = false;
            }

            setState(() {});
            previouseSearchQuery = _searchController.text;
          }
        } else {
          cities = null;
        }
      },
    );
    setState(() {});
  }

  @override
  void initState() {
    unawaited(_loadMapStyles());
    unawaited(_loadCustomRentIcon());
    unawaited(_loadCustomSelectedIcon());
    unawaited(_loadCustomSellIcon());
    unawaited(loadAll());
    _searchController.addListener(searchDelayTimer);
    super.initState();
  }

  LatLng getCameraPosition() {
    if (AppSettings.latitude.isNotEmpty && AppSettings.longitude.isNotEmpty) {
      return LatLng(
        double.parse(AppSettings.latitude),
        double.parse(AppSettings.longitude),
      );
    }
    return const LatLng(20.5937, 78.9629);
  }

  Future<void> loadAll() async {
    try {
      isLoadingProperty.value = true;
      final pointList = await GMap.getNearByProperty(
        '',
        '',
        '',
        '',
      );
      activePropertiesList = pointList;

      //Animate camera to location
      await loopMarker(pointList);
      isLoadingProperty.value = false;
    } on Exception catch (e) {
      isLoadingProperty.value = false;
      HelperUtils.showSnackBarMessage(
        context,
        '$e',
        type: .error,
      );
    } finally {
      isLoadingProperty.value = false;
    }
  }

  Future<void> onTapCity(int index) async {
    try {
      unawaited(Widgets.showLoader(context));
      final pointList = await GMap.getNearByProperty(
        cities?.elementAt(index).city ?? '',
        cities?.elementAt(index).latitude ?? '',
        cities?.elementAt(index).longitude ?? '',
        cities?.elementAt(index).placeId ?? '',
      );

      if (pointList.isEmpty) {
        marker = {};
        setState(() {});
      }

      final latLng = await getCityLatLong(
        latitude: cities?.elementAt(index).latitude ?? '',
        longitude: cities?.elementAt(index).longitude ?? '',
        placeId: cities?.elementAt(index).placeId ?? '',
      );

      try {
        final controller = await completer.future.timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            throw TimeoutException('Map controller not available');
          },
        );
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 7),
          ),
        );
      } on Exception catch (e) {
        HelperUtils.showSnackBarMessage(
          context,
          '$e',
          type: .error,
        );
      }

      await loopMarker(pointList);
      _searchFocus.unfocus();
      HelperUtils.unfocus();
      Future.delayed(
        Duration.zero,
        () {
          Widgets.hideLoder(context);
        },
      );
      cities = null;
      setState(() {});
    } on Exception catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
    }
  }

  Future<void> _loadCustomRentIcon() async {
    customIconRent = await BitmapDescriptor.asset(
      width: iconWidth,
      height: iconHeight,
      const ImageConfiguration(size: Size(50, 100)),
      'assets/location_rent.png',
    );
    setState(() {});
  }

  Future<void> _loadCustomSelectedIcon() async {
    customIconSelected = await BitmapDescriptor.asset(
      width: iconWidth,
      height: iconHeight,
      const ImageConfiguration(size: Size(50, 100)),
      'assets/location_selected.png',
    );
    setState(() {});
  }

  Future<void> _loadCustomSellIcon() async {
    customIconSell = await BitmapDescriptor.asset(
      width: iconWidth,
      height: iconHeight,
      const ImageConfiguration(size: Size(50, 100)),
      'assets/location_sell.png',
    );
    setState(() {});
  }

  Future<void> loopMarker(List<PropertyModel> pointList) async {
    marker.clear(); // Clear existing markers
    for (var i = 0; i < pointList.length; i++) {
      final element = pointList[i];

      // Create a custom icon for each marker with its property name

      // Safely parse latitude and longitude with error handling
      double? lat;
      double? lng;

      try {
        lat = element.latitude!.isNotEmpty
            ? double.parse(element.latitude!)
            : null;
        lng = element.longitude!.isNotEmpty
            ? double.parse(element.longitude!)
            : null;
      } on Exception catch (_) {
        // Skip this marker if parsing fails
        continue;
      }

      // Only add marker if both lat and lng are valid
      if (lat != null && lng != null) {
        marker.add(
          Marker(
            icon: selectedMarker == i
                ? customIconSelected
                : element.propertyType.toString().toLowerCase() == 'sell'
                ? customIconSell
                : customIconRent,
            markerId: MarkerId('$i'),
            onTap: () async {
              try {
                selectedMarker = i;
                propertyId = element.id;

                activePropertyModal = element;
                await loopMarker(pointList);
                setState(() {});
              } on Exception catch (e) {
                HelperUtils.showSnackBarMessage(
                  context,
                  '$e',
                  type: .error,
                );
              }
            },
            position: LatLng(lat, lng),
          ),
        );
      }
    }
    setState(() {});
  }

  Future<LatLng> getCityLatLong({
    required String latitude,
    required String longitude,
    required String placeId,
  }) async {
    final rawCityLatLong = await GooglePlaceRepository().getPlaceDetails(
      latitude: latitude,
      longitude: longitude,
      placeId: placeId,
    );

    final citylatLong = LatLng(
      rawCityLatLong['lat'] as double,
      rawCityLatLong['lng'] as double,
    );
    return citylatLong;
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget buildSearchIcon({required VoidCallback onTap, required bool isClose}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        child: CustomImage(
          imageUrl: isClose ? AppIcons.closeCircle : AppIcons.search,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        _googleMapController?.dispose();
        (await completer.future).dispose();
        showGoogleMap = false;
        setState(() {});
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: CustomAppBar(
          title: 'propertyMap'.translate(context),
        ),
        body: Stack(
          children: [
            // Map View
            if (showGoogleMap)
              GoogleMap(
                onCameraMove: (position) {
                  HelperUtils.unfocus();
                },
                style: context.color.brightness == .dark ? _darkMapStyle : null,
                markers: marker,
                onMapCreated: (controller) {
                  if (!completer.isCompleted) {
                    completer.complete(controller);
                    isMapCreated = true;
                  } else {}
                  showSellRentLables = true;
                  setState(() {});
                },
                onTap: (argument) {
                  activePropertyModal = null;
                  selectedMarker = 99999999999999;
                  setState(() {});
                },
                compassEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: getCameraPosition(),
                  zoom: 3,
                ),
              ),

            // Sell Rent Lable
            PositionedDirectional(
              top: 68.rh(context),
              start: 8.rw(context),
              end: 0,
              child: sellRentLable(context),
            ),

            // Cities List
            if (cities != null)
              ColoredBox(
                color: context.color.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: kBottomNavigationBarHeight,
                  ),
                  child: ListView.builder(
                    itemCount: cities?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          activePropertyModal = null;
                          setState(() {});
                          await onTapCity(index);
                        },
                        leading: SvgPicture.asset(
                          AppIcons.location,
                          colorFilter: ColorFilter.mode(
                            context.color.textColorDark,
                            .srcIn,
                          ),
                        ),
                        title: CustomText(
                          cities?.elementAt(index).city ?? '',
                        ),
                        subtitle: CustomText(
                          "${cities?.elementAt(index).state ?? ""},${cities?.elementAt(index).country ?? ""}",
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Loading Indicator
            PositionedDirectional(
              top: 68.rh(context),
              end: 8.rw(context),
              child: ValueListenableBuilder(
                valueListenable: isLoadingProperty,
                builder: (context, va, c) {
                  if (!va) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsetsDirectional.only(
                      end: 8,
                      top: 8,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: Color.lerp(
                        context.color.tertiaryColor,
                        context.color.secondaryColor,
                        0.8,
                      ),
                    ),
                    child: UiUtils.progress(
                      height: 20.rh(context),
                      width: 20.rw(context),
                    ),
                  );
                },
              ),
            ),

            // Active Property Modal
            PositionedDirectional(
              bottom: 8,
              child: cities != null
                  ? const SizedBox.shrink()
                  : activePropertyModal != null
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: PropertyHorizontalCard(
                          showLikeButton: false,
                          property: activePropertyModal!,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Search Bar
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: Container(
                width: context.screenWidth,
                padding: const EdgeInsets.all(16),
                child: CustomTextFormField(
                  controller: _searchController,
                  borderColor: Colors.transparent,
                  fillColor: context.color.secondaryColor,
                  hintText: 'searchHintLbl'.translate(context),
                  prefix: buildSearchIcon(
                    isClose: cities != null,
                    onTap: () {
                      if (cities != null) {
                        cities = null;
                        _searchController.text = '';
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding sellRentLable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: context.color.borderColor),
              borderRadius: BorderRadius.circular(4),
              color: context.color.secondaryColor,
            ),
            child: Row(
              children: [
                Container(
                  width: 18.rw(context),
                  height: 18.rh(context),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                CustomText(
                  'sell'.translate(context),
                  color: context.color.inverseSurface,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: context.color.borderColor),
              borderRadius: BorderRadius.circular(4),
              color: context.color.secondaryColor,
            ),
            child: Row(
              children: [
                Container(
                  width: 18.rw(context),
                  height: 18.rh(context),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                CustomText(
                  'rent'.translate(context),
                  color: context.color.inverseSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
