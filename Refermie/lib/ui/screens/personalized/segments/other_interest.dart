part of '../personalized_property_screen.dart';

class OtherInterests extends StatefulWidget {
  const OtherInterests({
    required this.onInteraction,
    required this.type,
    super.key,
  });

  final PersonalizedVisitType type;
  final dynamic Function(
    RangeValues priceRange,
    String location,
    List<int> propertyType,
  )
  onInteraction;

  @override
  State<OtherInterests> createState() => _OtherInterestsState();
}

class _OtherInterestsState extends State<OtherInterests> {
  String selectedLocation = '';
  final TextEditingController _cityController = TextEditingController();
  late final double min = personalizedInterestSettings.priceRange.first;
  late final double max = personalizedInterestSettings.priceRange.last;
  RangeValues _priceRangeValues = const RangeValues(0, 100);
  RangeValues _selectedRangeValues = const RangeValues(0, 50);
  final _minTextController = TextEditingController();
  final _maxTextController = TextEditingController();

  GooglePlaceRepository googlePlaceRepository = GooglePlaceRepository();
  List<int> selectedPropertyType = [0, 1];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        selectedPropertyType = personalizedInterestSettings.propertyType;
        _minTextController.text = personalizedInterestSettings.priceRange.first
            .toString();
        _maxTextController.text = personalizedInterestSettings.priceRange.last
            .toString();
        if (personalizedInterestSettings.city.isNotEmpty) {
          _cityController.text = personalizedInterestSettings.city
              .firstUpperCase();
          selectedLocation = personalizedInterestSettings.city;
        }

        widget.onInteraction.call(
          _selectedRangeValues,
          selectedLocation,
          selectedPropertyType,
        );
        setState(() {});
        final state = context.read<FetchSystemSettingsCubit>().state;
        if (state is FetchSystemSettingsSuccess) {
          final settingsData = state.settings['data'];
          final minPrice = double.parse(
            settingsData['min_price']?.toString() ?? '',
          );
          final maxPrice = double.parse(
            settingsData['max_price']?.toString() ?? '',
          );
          _priceRangeValues = RangeValues(minPrice, maxPrice);
          if (min != 0.0 && max != 0.0) {
            _selectedRangeValues = RangeValues(min, max);
          } else {
            _selectedRangeValues = RangeValues(minPrice, maxPrice / 4);
          }
          // Update text controllers with initial values
          _updateTextControllers(_selectedRangeValues);
        }
      },
    );

    // Add listeners to text controllers
    _minTextController.addListener(_handleMinTextChange);
    _maxTextController.addListener(_handleMaxTextChange);

    super.initState();
  }

  @override
  void dispose() {
    // Remove listeners when disposing
    _minTextController.removeListener(_handleMinTextChange);
    _maxTextController.removeListener(_handleMaxTextChange);
    _minTextController.dispose();
    _maxTextController.dispose();
    super.dispose();
  }

  // Update text controllers when range slider changes
  void _updateTextControllers(RangeValues values) {
    _minTextController.text = values.start.toInt().toString();
    _maxTextController.text = values.end.toInt().toString();
  }

  // Handle changes in minimum value text field
  void _handleMinTextChange() {
    if (_minTextController.text.isEmpty) return;

    var newStart = double.tryParse(_minTextController.text);
    if (newStart != null) {
      if (newStart < _priceRangeValues.start) {
        newStart = _priceRangeValues.start;
        _minTextController.text = newStart.toInt().toString();
      }
      if (newStart > _selectedRangeValues.end) {
        newStart = _selectedRangeValues.end;
        _minTextController.text = newStart.toInt().toString();
      }

      setState(() {
        _selectedRangeValues = RangeValues(newStart!, _selectedRangeValues.end);
      });
      widget.onInteraction.call(
        _selectedRangeValues,
        selectedLocation,
        selectedPropertyType,
      );
    }
  }

  // Handle changes in maximum value text field
  void _handleMaxTextChange() {
    if (_maxTextController.text.isEmpty) return;

    var newEnd = double.tryParse(_maxTextController.text);
    if (newEnd != null) {
      if (newEnd > _priceRangeValues.end) {
        newEnd = _priceRangeValues.end;
        _maxTextController.text = newEnd.toInt().toString();
      }
      if (newEnd < _selectedRangeValues.start) {
        newEnd = _selectedRangeValues.start;
        _maxTextController.text = newEnd.toInt().toString();
      }

      setState(() {
        _selectedRangeValues = RangeValues(_selectedRangeValues.start, newEnd!);
      });
      widget.onInteraction.call(
        _selectedRangeValues,
        selectedLocation,
        selectedPropertyType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirstTime = widget.type == PersonalizedVisitType.firstTime;
    final currencySymbol = context.read<FetchSystemSettingsCubit>().getSetting(
      SystemSetting.currencySymbol,
    );
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'personalizedFeed'.translate(context),
        actions: [
          if (isFirstTime)
            GestureDetector(
              onTap: () async {
                await HelperUtils.killPreviousPages(
                  context,
                  Routes.main,
                  {'from': 'login'},
                );
              },
              child: Chip(
                label: CustomText(
                  'skip'.translate(context),
                  color: context.color.buttonColor,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              CustomText(
                'selectCityYouWantToSee'.translate(context),
                maxLines: 2,
                fontSize: context.font.md,
                color: context.color.textColorDark,
                fontWeight: .w500,
              ),
              const SizedBox(
                height: 24,
              ),
              CustomText(
                'city'.translate(context),
                fontSize: context.font.sm,
                color: context.color.textColorDark,
                fontWeight: .w400,
              ),
              const SizedBox(height: 8),
              buildCitySearchTextField(context),
              if (selectedLocation.isNotEmpty) ...[
                const SizedBox(
                  height: 8,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      CustomText(
                        'selectedLocation'.translate(context),
                        fontSize: context.font.sm,
                        fontWeight: .w500,
                        color: context.color.textColorDark,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CustomText(
                          selectedLocation,
                          fontSize: context.font.md,
                          fontWeight: .w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              CustomText(
                'choosePropertyType'.translate(context),
                fontSize: context.font.sm,
                color: context.color.textColorDark,
                fontWeight: .w500,
              ),
              const SizedBox(height: 8),
              PropertyTypeSelector(
                onInteraction: (List<int> values) {
                  selectedPropertyType = values;
                  widget.onInteraction.call(
                    _selectedRangeValues,
                    selectedLocation,
                    values,
                  );

                  setState(() {});
                },
              ),
              const SizedBox(height: 28),
              CustomText(
                'chooseTheBudeget'.translate(context),
                fontSize: context.font.md,
                color: context.color.textColorDark,
                fontWeight: .w500,
              ),
              const SizedBox(height: 24),
              CustomText(
                'budgetLbl'.translate(context),
                color: context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w400,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        action: .next,
                        controller: _minTextController,
                        isReadOnly: false,
                        prefix: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: CustomText(
                            currencySymbol.toString(),
                            fontSize: context.font.md,
                            fontWeight: .w500,
                            color: context.color.textColorDark,
                          ),
                        ),
                        keyboard: TextInputType.number,
                        validator: CustomTextFieldValidator.nullCheck,
                        hintText: 'min'.translate(context),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: CustomTextFormField(
                        action: .next,
                        controller: _maxTextController,
                        prefix: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: CustomText(
                            currencySymbol.toString(),
                            fontSize: context.font.md,
                            fontWeight: .w500,
                            color: context.color.textColorDark,
                          ),
                        ),
                        isReadOnly: false,
                        keyboard: TextInputType.number,
                        validator: CustomTextFieldValidator.nullCheck,
                        hintText: 'max'.translate(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CustomText(
                    'priceRange'.translate(context),
                    fontSize: context.font.sm,
                    color: context.color.textColorDark,
                    fontWeight: .w500,
                  ),
                  const SizedBox(width: 4),
                  CustomText(
                    '$currencySymbol ${_priceRangeValues.start.round()} ${'to'.translate(context).toUpperCase()} $currencySymbol ${_priceRangeValues.end.round()}',
                    fontSize: context.font.sm,
                    color: context.color.tertiaryColor,
                    fontWeight: .w400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RangeSlider(
                activeColor: context.color.tertiaryColor,
                inactiveColor: context.color.borderColor,
                values: _selectedRangeValues,
                onChanged: (RangeValues value) {
                  setState(() {
                    _selectedRangeValues = value;
                    _updateTextControllers(
                      value,
                    ); // Update text controllers when slider changes
                  });
                  widget.onInteraction.call(
                    _selectedRangeValues,
                    selectedLocation,
                    selectedPropertyType,
                  );
                },
                min: _priceRangeValues.start,
                max: _priceRangeValues.end,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCitySearchTextField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.color.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TypeAheadField(
        emptyBuilder: (context) => const SizedBox.shrink(),
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(
              color: context.color.textColorDark,
              fontSize: context.font.sm,
              fontWeight: .w400,
            ),
            decoration: InputDecoration(
              hintText: 'selectLocationOptional'.translate(context),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.color.tertiaryColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.color.tertiaryColor,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.color.tertiaryColor,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error) {
          return const CustomText('Error');
        },
        loadingBuilder: (context) {
          return Center(child: UiUtils.progress());
        },
        itemBuilder: (context, GooglePlaceModel itemData) {
          final address = <String>[
            itemData.city,
            itemData.state,
            itemData.country,
          ];

          return ListTile(
            tileColor: context.color.secondaryColor,
            title: CustomText(address.join(',')),
          );
        },
        suggestionsCallback: (String pattern) async {
          if (pattern.length < 2) {
            return Future.value(<GooglePlaceModel>[]);
          }
          return googlePlaceRepository.serchCities(
            pattern,
          );
        },
        onSelected: (GooglePlaceModel suggestion) {
          final addressList = <String>[
            suggestion.city,
            suggestion.state,
            suggestion.country,
          ];
          final address = addressList.join(',');
          _cityController.text = address;
          selectedLocation = address;
          widget.onInteraction.call(
            _selectedRangeValues,
            selectedLocation,
            selectedPropertyType,
          );

          FocusScope.of(context).unfocus();
          setState(() {});
        },
      ),
    );
  }
}

class PropertyTypeSelector extends StatefulWidget {
  const PropertyTypeSelector({
    required this.onInteraction,
    super.key,
  });

  final dynamic Function(List<int> values) onInteraction;

  @override
  State<PropertyTypeSelector> createState() => _PropertyTypeSelectorState();
}

class _PropertyTypeSelectorState extends State<PropertyTypeSelector> {
  List<int> selectedPropertyType = [0, 1];

  // Define dropdown options as static lists
  static const List<int> sellOption = [0];
  static const List<int> rentOption = [1];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        if (personalizedInterestSettings.propertyType.isNotEmpty) {
          // Match the saved property type with dropdown options
          final savedType = personalizedInterestSettings.propertyType;
          if (savedType.length == 1 && savedType[0] == 0) {
            selectedPropertyType = sellOption;
          } else if (savedType.length == 1 && savedType[0] == 1) {
            selectedPropertyType = rentOption;
          } else {
            // Default to sell if no exact match
            selectedPropertyType = sellOption;
          }
        }

        widget.onInteraction.call(selectedPropertyType);
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.rh(context),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.color.borderColor),
      ),
      child: DropdownButtonFormField<List<int>>(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        initialValue: selectedPropertyType,
        itemHeight: 48.rh(context),
        dropdownColor: context.color.secondaryColor,
        icon: CustomImage(
          imageUrl: AppIcons.downArrow,
          color: context.color.textColorDark,
        ),
        items: [
          DropdownMenuItem(
            value: sellOption,
            child: CustomText('sell'.translate(context)),
          ),
          DropdownMenuItem(
            value: rentOption,
            child: CustomText('rent'.translate(context)),
          ),
        ],
        onChanged: (value) {
          selectedPropertyType = value!;
          widget.onInteraction.call(selectedPropertyType);
          setState(() {});
        },
      ),
    );
  }
}
