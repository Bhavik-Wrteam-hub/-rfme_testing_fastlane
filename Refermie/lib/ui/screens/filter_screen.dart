// filter_screen.dart - Optimized version

import 'package:ebroker/data/cubits/utility/fetch_facilities_cubit.dart';
import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/bottom_sheets/choose_location_bottomsheet.dart';
import 'package:ebroker/utils/admob/banner_ad_load_widget.dart';
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    super.key,
    this.showPropertyType = false,
    this.selectedFilter,
  });

  final bool showPropertyType;
  final FilterApply? selectedFilter;

  @override
  FilterScreenState createState() => FilterScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => FilterScreen(
        selectedFilter: arguments?['filter'] as FilterApply? ?? FilterApply(),
        showPropertyType: arguments?['showPropertyType'] as bool? ?? false,
      ),
    );
  }
}

class FilterScreenState extends State<FilterScreen> {
  // Controllers
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  // Filter state
  late FilterApply _filter;

  // Location state
  String? _city;
  String? _state;
  String? _country;

  // Selection state
  Category? _selectedCategory;
  final Set<int> _selectedFacilities = {};

  // Constants for posted since options
  static const List<({PostedSinceDuration duration, String labelKey})>
  _postedSinceOptions = [
    (labelKey: 'anytimeLbl', duration: PostedSinceDuration.anytime),
    (labelKey: 'lastWeekLbl', duration: PostedSinceDuration.lastWeek),
    (labelKey: 'yesterdayLbl', duration: PostedSinceDuration.yesterday),
    (labelKey: 'lastMonthLbl', duration: PostedSinceDuration.lastMonth),
    (
      labelKey: 'lastThreeMonthLbl',
      duration: PostedSinceDuration.lastThreeMonth,
    ),
    (labelKey: 'lastSixMonthLbl', duration: PostedSinceDuration.lastSixMonth),
  ];

  //Nearby Places
  final Map<int, TextEditingController> distanceFieldList = {};

  @override
  void initState() {
    super.initState();
    _initializeFilter();
    _initializeControllers();
    unawaited(_fetchFacilities());
  }

  void _initializeFilter() {
    _filter = widget.selectedFilter?.copy() ?? FilterApply();

    // Initialize from existing filter
    final category = _filter.get<CategoryFilter>();
    final facilities = _filter.get<FacilitiesFilter>();
    final location = _filter.get<LocationFilter>();
    final nearbyPlaces = _filter.get<NearbyPlacesFilter>();

    // Set initial values
    if (category.categoryId != null) {
      _selectedCategory = Category(id: int.tryParse(category.categoryId!) ?? 0);
    }

    _selectedFacilities.addAll(facilities.facilities);

    _city = location.city;
    _state = location.state;
    _country = location.country;

    // Initialize nearby places controllers
    for (final place in nearbyPlaces.nearbyPlaces) {
      distanceFieldList[place.id] = TextEditingController(
        text: place.value,
      );
    }
  }

  void _initializeControllers() {
    final minMax = _filter.get<MinMaxBudget>();
    _minController = TextEditingController(text: minMax.min ?? '');
    _maxController = TextEditingController(text: minMax.max ?? '');
  }

  Future<void> _fetchFacilities() async {
    if (!mounted) return;
    await context.read<FetchFacilitiesCubit>().fetch();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    for (final controller in distanceFieldList.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _filter.clear();
      _minController.clear();
      _maxController.clear();
      _selectedCategory = null;
      _selectedFacilities.clear();
      _city = null;
      _state = null;
      _country = null;

      // Clear distance field controllers
      for (final controller in distanceFieldList.values) {
        controller.clear();
      }
    });
  }

  void _applyFilters() {
    // Update filter with current values
    _filter
      ..addOrUpdate(
        MinMaxBudget(
          min: _minController.text.trim().isEmpty ? null : _minController.text,
          max: _maxController.text.trim().isEmpty ? null : _maxController.text,
        ),
      )
      ..addOrUpdate(FacilitiesFilter(_selectedFacilities.toList()));

    // Add nearby places filter
    final nearbyPlaces = <NearbyPlace>[];
    for (final entry in distanceFieldList.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        final distance = int.tryParse(text);
        if (distance != null) {
          nearbyPlaces.add(
            NearbyPlace(
              id: entry.key,
              value: distance.toString(),
            ),
          );
        }
      }
    }

    if (nearbyPlaces.isNotEmpty) {
      _filter.addOrUpdate(NearbyPlacesFilter(nearbyPlaces));
    } else {
      _filter.remove<NearbyPlacesFilter>();
    }

    // Set category name for display
    if (widget.showPropertyType) {
      selectedcategoryName = _selectedCategory?.category ?? '';
    }

    Navigator.pop(context, _filter);
  }

  Future<void> _selectLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await showModalBottomSheet<GooglePlaceModel>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => const ChooseLocatonBottomSheet(),
    );

    if (result != null && mounted) {
      setState(() {
        _city = result.city;
        _country = result.country;
        _state = result.state;

        _filter.addOrUpdate(
          LocationFilter(
            placeId: result.placeId,
            city: result.city,
            state: result.state,
            country: result.country,
          ),
        );
      });
    }
  }

  void _clearLocation() {
    setState(() {
      _city = null;
      _state = null;
      _country = null;
      _filter.remove<LocationFilter>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: CustomAppBar(
          title: 'filterTitle'.translate(context),
        ),
        bottomNavigationBar: _buildBottomBar(),
        body: SingleChildScrollView(
          physics: Constant.scrollPhysics,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 8),
              _buildPropertyTypeToggle(),
              if (widget.showPropertyType) ...[
                const SizedBox(height: 16),
                _buildCategorySection(),
              ],
              const SizedBox(height: 16),
              _buildBudgetSection(),
              const SizedBox(height: 16),
              _buildPostedSinceSection(),
              const SizedBox(height: 16),
              _buildLocationSection(),
              const SizedBox(height: 16),
              _buildFacilitiesSection(),
              const SizedBox(height: 16),
              _buildOutdoorFacilitiesSection(),
              const SizedBox(height: 16),
              const Center(
                child: BannerAdWidget(bannerSize: AdSize.banner),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      height: 72.rh(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.color.primaryColor,
      child: Row(
        children: [
          Expanded(
            child: UiUtils.buildButton(
              context,
              onPressed: _resetFilters,
              buttonColor: context.color.secondaryColor,
              showElevation: false,
              textColor: context.color.textColorDark,
              buttonTitle: 'clearfilter'.translate(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: UiUtils.buildButton(
              context,
              buttonTitle: 'applyFilter'.translate(context),
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeToggle() {
    final propertyType = _filter.get<PropertyTypeFilter>().type;

    return Container(
      decoration: BoxDecoration(
        color: context.color.tertiaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: context.color.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                title: 'forSell'.translate(context),
                isSelected: propertyType == Constant.valSellBuy,
                onTap: () {
                  setState(() {
                    _filter.addOrUpdate(
                      PropertyTypeFilter(
                        propertyType == Constant.valSellBuy
                            ? ''
                            : Constant.valSellBuy,
                      ),
                    );
                  });
                },
              ),
            ),
            Expanded(
              child: _buildToggleButton(
                title: 'forRent'.translate(context),
                isSelected: propertyType == Constant.valRent,
                onTap: () {
                  setState(() {
                    _filter.addOrUpdate(
                      PropertyTypeFilter(
                        propertyType == Constant.valRent
                            ? ''
                            : Constant.valRent,
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return UiUtils.buildButton(
      context,
      height: 48.rh(context),
      onPressed: onTap,
      showElevation: false,
      textColor: isSelected
          ? context.color.buttonColor
          : context.color.textColorDark,
      buttonColor: isSelected
          ? context.color.tertiaryColor
          : Colors.transparent,
      fontSize: context.font.md,
      buttonTitle: title,
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          'proeprtyType'.translate(context),
          fontSize: context.font.sm,
        ),
        const SizedBox(height: 8),
        BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
          builder: (context, state) {
            if (state is! FetchCategorySuccess) return const SizedBox.shrink();

            final categories = [null, ...state.categories];

            return SizedBox(
              height: 32.rh(context),
              child: ListView.separated(
                scrollDirection: .horizontal,
                physics: Constant.scrollPhysics,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      category == _selectedCategory ||
                      (category == null && _selectedCategory == null);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _filter.addOrUpdate(
                          CategoryFilter(category?.id?.toString()),
                        );
                      });
                    },
                    child: _buildCategoryChip(category, isSelected),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChip(Category? category, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? context.color.tertiaryColor
            : context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.color.borderColor),
      ),
      child: category == null
          ? CustomText(
              'lblall'.translate(context),
              color: isSelected
                  ? context.color.buttonColor
                  : context.color.textColorDark,
            )
          : Row(
              children: [
                CustomImage(
                  imageUrl: category.image!,
                  height: 18.rh(context),
                  width: 18.rw(context),
                  color: isSelected
                      ? context.color.buttonColor
                      : context.color.tertiaryColor,
                ),
                const SizedBox(width: 8),
                CustomText(
                  category.translatedName ?? category.category ?? '',
                  color: isSelected
                      ? context.color.buttonColor
                      : context.color.textColorDark,
                ),
              ],
            ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText('budgetLbl'.translate(context), fontSize: context.font.sm),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildBudgetField(
                controller: _minController,
                label: 'minLbl'.translate(context),
                validator: _validateMin,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBudgetField(
                controller: _maxController,
                label: 'maxLbl'.translate(context),
                validator: _validateMax,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: .done,
      validator: validator,
      decoration: InputDecoration(
        isDense: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: context.color.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: context.color.borderColor),
        ),
        labelStyle: TextStyle(color: context.color.textColorDark),
        hintText: '00',
        label: CustomText(label),
        prefixText: '${Constant.currencySymbol} ',
        prefixStyle: TextStyle(color: context.color.textColorDark),
        fillColor: context.color.secondaryColor,
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(color: context.color.textColorDark),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  String? _validateMin(String? value) {
    if (value?.isEmpty ?? true) return null;
    if (_maxController.text.isEmpty) return null;

    final min = num.tryParse(value!) ?? 0;
    final max = num.tryParse(_maxController.text) ?? 0;

    if (min >= max) {
      return '${'enterSmallerThan'.translate(context)} ${_maxController.text}';
    }
    return null;
  }

  String? _validateMax(String? value) {
    if (value?.isEmpty ?? true) return null;
    if (_minController.text.isEmpty) return null;

    final max = num.tryParse(value!) ?? 0;
    final min = num.tryParse(_minController.text) ?? 0;

    if (max <= min) {
      return '${'enterBiggerThan'.translate(context)} ${_minController.text}';
    }
    return null;
  }

  Widget _buildPostedSinceSection() {
    final currentDuration = _filter.get<PostedSince>().since;

    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          'postedSinceLbl'.translate(context),
          fontSize: context.font.sm,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32.rh(context),
          child: ListView.separated(
            scrollDirection: .horizontal,
            shrinkWrap: true,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: _postedSinceOptions.length,
            itemBuilder: (context, index) {
              final option = _postedSinceOptions[index];
              final isSelected = currentDuration == option.duration;

              return UiUtils.buildButton(
                context,
                fontSize: context.font.sm,
                showElevation: false,
                autoWidth: true,
                border: BorderSide(color: context.color.borderColor),
                buttonColor: isSelected
                    ? context.color.tertiaryColor
                    : context.color.secondaryColor,
                textColor: isSelected
                    ? context.color.secondaryColor
                    : context.color.textColorDark,
                buttonTitle: option.labelKey.translate(context),
                onPressed: () {
                  setState(() {
                    _filter.addOrUpdate(PostedSince(option.duration));
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final hasLocation = _city != null && _city!.isNotEmpty;

    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText('locationLbl'.translate(context), fontSize: context.font.sm),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48.rh(context),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: context.color.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        hasLocation
                            ? '$_city, $_state, $_country'
                            : 'selectLocationOptional'.translate(context),
                        maxLines: 1,
                      ),
                    ),
                    if (hasLocation)
                      GestureDetector(
                        onTap: _clearLocation,
                        child: Icon(
                          Icons.close,
                          color: context.color.textColorDark,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _selectLocation,
              child: Container(
                height: 48.rh(context),
                width: 48.rh(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: context.color.borderColor),
                ),
                child: CustomImage(
                  imageUrl: AppIcons.location,
                  height: 24.rh(context),
                  width: 24.rw(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    return BlocBuilder<FetchFacilitiesCubit, FetchFacilitiesState>(
      builder: (context, state) {
        if (state is! FetchFacilitiesSuccess || state.facilities.isEmpty) {
          return const SizedBox.shrink();
        }

        return ExpansionTile(
          shape: const Border(),
          title: CustomText('facilities'.translate(context)),
          textColor: context.color.tertiaryColor,
          iconColor: context.color.tertiaryColor,
          backgroundColor: Colors.transparent,
          clipBehavior: .none,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isLargeTablet(context) ? 4 : 3,
                mainAxisExtent: 48.rh(context),
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 3,
              ),
              itemCount: state.facilities.length,
              itemBuilder: (context, index) {
                final facility = state.facilities[index];
                final isSelected = _selectedFacilities.contains(facility.id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedFacilities.remove(facility.id);
                      } else {
                        _selectedFacilities.add(facility.id!);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.color.tertiaryColor
                          : context.color.secondaryColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: context.color.borderColor),
                    ),
                    child: CustomText(
                      textAlign: .center,
                      facility.translatedName ?? facility.name ?? '',
                      maxLines: 2,
                      color: isSelected
                          ? context.color.buttonColor
                          : context.color.textColorDark,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// New version: Just show a list of facilities with distance input
  Widget _buildOutdoorFacilitiesSection() {
    return BlocBuilder<FetchFacilitiesCubit, FetchFacilitiesState>(
      builder: (context, state) {
        if (state is! FetchFacilitiesSuccess ||
            state.outdoorFacilities.isEmpty) {
          return const SizedBox.shrink();
        }

        final facilities = state.outdoorFacilities;

        return Column(
          crossAxisAlignment: .start,
          children: [
            CustomText(
              'chooseNearbyPlaces'.translate(context),
              fontSize: context.font.sm,
              fontWeight: .w400,
            ),
            const SizedBox(height: 12),
            ListView.separated(
              itemCount: facilities.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final facility = facilities[index];

                // Ensure controller exists
                distanceFieldList.putIfAbsent(
                  facility.id!,
                  TextEditingController.new,
                );

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: context.color.borderColor),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      SizedBox(
                        height: 32.rh(context),
                        width: 32.rw(context),
                        child: CustomImage(
                          imageUrl: facility.image ?? '',
                          color: context.color.textColorDark,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Facility name
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          facility.translatedName ?? facility.name ?? '',
                          color: context.color.textColorDark,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Distance input
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: distanceFieldList[facility.id],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            color: context.color.textColorDark,
                          ),
                          decoration: InputDecoration(
                            hintText: AppSettings.distanceOption,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: context.color.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: context.color.borderColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: context.color.borderColor,
                              ),
                            ),
                            isDense: true,
                            fillColor: context.color.secondaryColor,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
