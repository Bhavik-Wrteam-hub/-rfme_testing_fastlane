import 'package:ebroker/data/model/outdoor_facility.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/property_success.dart';
import 'package:ebroker/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';

class SelectOutdoorFacility extends StatefulWidget {
  const SelectOutdoorFacility({required this.apiParameters, super.key});

  final Map<String, dynamic>? apiParameters;

  static Route<dynamic> route(RouteSettings settings) {
    final apiParameters = settings.arguments as Map<String, dynamic>? ?? {};
    return CupertinoPageRoute(
      builder: (context) {
        return SelectOutdoorFacility(
          apiParameters: apiParameters,
        );
      },
    );
  }

  @override
  State<SelectOutdoorFacility> createState() => _SelectOutdoorFacilityState();
}

class _SelectOutdoorFacilityState extends State<SelectOutdoorFacility> {
  final ValueNotifier<List<int>> _selectedIdsList = ValueNotifier([]);
  List<OutdoorFacility> facilityList = [];
  Map<int, TextEditingController> distanceFieldList = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    var facilities = <AssignedOutdoorFacility>[];
    facilities = (widget.apiParameters?['assign_facilities'] as List? ?? [])
        .cast<AssignedOutdoorFacility>();

    // context.read<FetchOutdoorFacilityListCubit>().fetchIfFailed();
    facilityList = context.read<FetchOutdoorFacilityListCubit>().getList();

    setState(() {});
    _selectedIdsList.addListener(() {
      for (final element in _selectedIdsList.value) {
        if (!distanceFieldList.keys.contains(element)) {
          if (widget.apiParameters?['isUpdate'] as bool? ?? false) {
            final match = facilities
                .where((x) => x.facilityId == element.toString())
                .toList();

            if (match.isNotEmpty) {
              distanceFieldList[element] = TextEditingController(
                text: match.first.distance.toString(),
              );
            } else {
              distanceFieldList[element] = TextEditingController();
            }
          } else {
            distanceFieldList[element] = TextEditingController();
          }
        }
      }
      setState(() {});
    });

    if (widget.apiParameters?['isUpdate'] as bool? ?? false) {
      for (final element in facilities) {
        if (!_selectedIdsList.value.contains(
          int.parse(element.facilityId ?? ''),
        )) {
          final updatedList = List<int>.from(_selectedIdsList.value)
            ..add(int.parse(element.facilityId ?? ''));
          _selectedIdsList.value = updatedList;
        }
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _selectedIdsList.dispose();
    for (final controller in distanceFieldList.values) {
      controller.dispose();
    }
    distanceFieldList.clear();
    super.dispose();
  }

  Map<String, dynamic> assembleOutdoorFacility() {
    final facilitymap = <String, dynamic>{};
    for (var i = 0; i < distanceFieldList.entries.length; i++) {
      final element =
          distanceFieldList.entries.elementAt(i) as MapEntry<dynamic, dynamic>;

      facilitymap.addAll({
        'facilities[$i][facility_id]': element.key,
        'facilities[$i][distance]': element.value.text,
      });
    }

    return facilitymap;
  }

  OutdoorFacility getSelectedFacility(int id) {
    try {
      return facilityList
          .where((OutdoorFacility element) => element.id == id)
          .first;
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // log(facilityList.toString());
    final fetchInProgress =
        context.watch<FetchOutdoorFacilityListCubit>().state
            is FetchOutdoorFacilityListInProgress;
    final fetchFails =
        context.watch<FetchOutdoorFacilityListCubit>().state
            is FetchOutdoorFacilityListInProgress;

    return BlocListener<
      FetchOutdoorFacilityListCubit,
      FetchOutdoorFacilityListState
    >(
      listener: (context, state) {
        if (state is FetchOutdoorFacilityListSucess) {
          facilityList = context
              .read<FetchOutdoorFacilityListCubit>()
              .getList();
          setState(() {});
        }
      },
      child: BlocListener<CreatePropertyCubit, CreatePropertyState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state is CreatePropertyInProgress) {
            unawaited(Widgets.showLoader(context));
          }
          if (state is CreatePropertyFailure) {
            Widgets.hideLoder(context);
            HelperUtils.showSnackBarMessage(context, state.errorMessage);
          }
          if (state is CreatePropertySuccess) {
            Widgets.hideLoder(context);
          }
          if (state is CreatePropertySuccess) {
            Widgets.hideLoder(context);
            if (widget.apiParameters?['isUpdate'] == false) {
              ref[propertyType ?? 'sell']?.fetchMyProperties(
                type: propertyType ?? 'sell',
              );
              Future.delayed(
                Duration.zero,
                () async {
                  await Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute<dynamic>(
                      builder: (context) {
                        return PropertyAddSuccess(
                          model: state.propertyModel!,
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              context.read<PropertyEditCubit>().add(state.propertyModel!);
              context.read<FetchMyPropertiesCubit>().update(
                state.propertyModel!,
              );
              cubitReference?.update(state.propertyModel!);
              Widgets.hideLoder(context);
              Future.delayed(
                Duration.zero,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (context) {
                        return PropertyAddSuccess(
                          model: state.propertyModel!,
                        );
                      },
                    ),
                  );
                },
              );
            }
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: context.color.backgroundColor,
            appBar: CustomAppBar(
              title: 'selectNearestPlaces'.translate(context),
              actions: [
                CustomText(
                  '4/4',
                  fontSize: context.font.sm,
                  fontWeight: .w500,
                  color: context.color.textColorDark,
                ),
              ],
            ),
            bottomNavigationBar: GestureDetector(
              onTap: () {
                distanceFieldList.forEach((element, v) {});
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: UiUtils.buildButton(
                  context,
                  height: 48.rh(context),
                  onPressed: () async {
                    final parameters = widget.apiParameters;

                    ///adding facility data to api payload
                    parameters!.addAll(assembleOutdoorFacility());
                    parameters
                      ..remove('assign_facilities')
                      ..remove('isUpdate');
                    if (_formKey.currentState!.validate()) {
                      await context.read<CreatePropertyCubit>().create(
                        parameters: parameters,
                      );
                    }
                  },
                  buttonTitle: widget.apiParameters?['action_type'] == '0'
                      ? 'update'.translate(context)
                      : 'submitProperty'.translate(context),
                ),
              ),
            ),
            body: Builder(
              builder: (context) {
                if (fetchInProgress) {
                  return Center(
                    child: UiUtils.progress(),
                  );
                }
                if (fetchFails) {
                  return const Center(
                    child: CustomText('Something Went wrong'),
                  );
                }
                return SingleChildScrollView(
                  physics: Constant.scrollPhysics,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          12,
                          16,
                          0,
                        ),
                        child: CustomText('selectPlaces'.translate(context)),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<
                        FetchOutdoorFacilityListCubit,
                        FetchOutdoorFacilityListState
                      >(
                        builder: (context, state) {
                          if (state is FetchOutdoorFacilityListFailure) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: SomethingWentWrong(
                                errorMessage: state.error.toString(),
                              ),
                            );
                          }
                          if (state is FetchOutdoorFacilityListSucess &&
                              state.outdoorFacilityList.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: NoDataFound(
                                title: 'noOutdoorFacilityFound'.translate(
                                  context,
                                ),
                                description: 'noOutdoorFacilityFoundDescription'
                                    .translate(context),
                                onTapRetry: () async {
                                  await context
                                      .read<FetchOutdoorFacilityListCubit>()
                                      .fetch();
                                },
                              ),
                            );
                          }
                          if (state is FetchOutdoorFacilityListSucess &&
                              state.outdoorFacilityList.isNotEmpty) {
                            return ValueListenableBuilder<List<int>>(
                              valueListenable: _selectedIdsList,
                              builder: (context, List<int> value, child) {
                                return OutdoorFacilityTable(
                                  length: state.outdoorFacilityList.length,
                                  child: (index) {
                                    final outdoorFacilityList =
                                        state.outdoorFacilityList[index];

                                    return buildTypeCard(
                                      index,
                                      context,
                                      outdoorFacilityList,
                                      onSelect: (id) {
                                        if (_selectedIdsList.value.contains(
                                          id,
                                        )) {
                                          final updatedList = List<int>.from(
                                            _selectedIdsList.value,
                                          )..remove(id);
                                          _selectedIdsList.value = updatedList;

                                          ///Dispose and remove from object
                                          distanceFieldList[id]?.dispose();
                                          distanceFieldList.remove(id);
                                        } else {
                                          final updatedList = List<int>.from(
                                            _selectedIdsList.value,
                                          )..add(id);
                                          _selectedIdsList.value = updatedList;
                                        }
                                      },
                                      isSelected: value.contains(
                                        outdoorFacilityList.id,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }

                          return Container();
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _selectedIdsList,
                        builder: (context, value, child) {
                          return Padding(
                            padding: const EdgeInsets.all(15),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  if (_selectedIdsList.value.isEmpty)
                                    const SizedBox.shrink()
                                  else
                                    CustomText(
                                      'selectedItems'.translate(context),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ...List.generate(
                                    _selectedIdsList.value.length,
                                    (index) {
                                      if (fetchInProgress) {
                                        return const SizedBox.shrink();
                                      }

                                      final facility = getSelectedFacility(
                                        _selectedIdsList.value[index],
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                        ),
                                        child: OutdoorFacilityDistanceField(
                                          facility: facility,
                                          controller:
                                              distanceFieldList[facility.id]!,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTypeCard(
    int index,
    BuildContext context,
    OutdoorFacility facility, {
    required bool isSelected,
    required dynamic Function(int id) onSelect,
  }) {
    return GestureDetector(
      onTap: () {
        onSelect.call(facility.id!);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? context.color.tertiaryColor
              : context.color.secondaryColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    offset: const Offset(1, 3),
                    blurRadius: 6,
                    color: context.color.tertiaryColor.withValues(alpha: 0.2),
                  ),
                ]
              : null,
          border: isSelected
              ? null
              : Border.all(color: context.color.borderColor),
        ),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              height: 26.rh(context),
              width: 26.rw(context),
              child: CustomImage(
                imageUrl: facility.image ?? '',
                color: isSelected
                    ? context.color.buttonColor
                    : context.color.textColorDark,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2),
              child: CustomText(
                facility.translatedName ?? facility.name ?? '',
                textAlign: .center,
                color: isSelected
                    ? context.color.buttonColor
                    : context.color.textColorDark,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutdoorFacilityDistanceField extends StatelessWidget {
  const OutdoorFacilityDistanceField({
    required this.facility,
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  final OutdoorFacility facility;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.rw(context),
          height: 48.rh(context),
          decoration: BoxDecoration(
            color: context.color.tertiaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FittedBox(
            fit: .none,
            child: SizedBox(
              height: 24.rh(context),
              width: 24.rw(context),
              child: CustomImage(
                imageUrl: facility.image ?? '',
                color: context.color.tertiaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomText(
              facility.translatedName ?? facility.name ?? '',
              maxLines: 3,
            ),
          ),
        ),
        Expanded(
          child: CustomTextFormField(
            keyboard: TextInputType.number,
            validator: CustomTextFieldValidator.nullCheck,
            hintText: '00',
            formaters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            controller: controller,
            suffix: Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: CustomText(
                AppSettings.distanceOption.translate(context).firstUpperCase(),
                color: context.color.textLightColor,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}

class OutdoorFacilityWithController {
  const OutdoorFacilityWithController({
    required this.facility,
    required this.controller,
  });

  factory OutdoorFacilityWithController.fromMap(Map<String, dynamic> map) {
    return OutdoorFacilityWithController(
      facility: map['facility'] as OutdoorFacility,
      controller: map['controller'] as TextEditingController,
    );
  }

  final OutdoorFacility facility;
  final TextEditingController controller;

  @override
  String toString() {
    return 'OutdoorFacilityWithController{ facility: $facility, controller: $controller,}';
  }

  OutdoorFacilityWithController copyWith({
    OutdoorFacility? facility,
    TextEditingController? controller,
  }) {
    return OutdoorFacilityWithController(
      facility: facility ?? this.facility,
      controller: controller ?? this.controller,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'facility': facility,
      'controller': controller,
    };
  }
}

class OutdoorFacilityTable extends StatefulWidget {
  const OutdoorFacilityTable({
    required this.child,
    required this.length,
    super.key,
  });

  final int length;
  final Widget Function(int index) child;

  @override
  State<OutdoorFacilityTable> createState() => _OutdoorFacilityTableState();
}

class _OutdoorFacilityTableState extends State<OutdoorFacilityTable> {
  final PageController _pageController = PageController();
  int rowCount = 3;
  Map<dynamic, dynamic>? sizeMap = {};
  int colCount = 3;
  late int totalData = widget.length;
  int itemsPerPage = 9;
  int selectedPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 290.rh(context),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              selectedPage = value;
              setState(() {});
            },
            physics: Constant.scrollPhysics,
            itemCount: (totalData / itemsPerPage).ceil(),
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * itemsPerPage;
              final endIndex = (startIndex + itemsPerPage) > totalData
                  ? totalData
                  : (startIndex + itemsPerPage);

              final gridData = List.generate(
                endIndex - startIndex,
                (index) {
                  return 'Data ${startIndex + index + 1}';
                },
              );

              final pageKey = Key(pageIndex.toString());
              return GridView.builder(
                shrinkWrap: true,
                key: pageKey,
                physics: Constant.scrollPhysics,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                      crossAxisCount: colCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      height: 85.rh(context),
                    ),
                itemCount: gridData.length,
                itemBuilder: (BuildContext c, int index) {
                  final dataIndex = startIndex + index;
                  return widget.child.call(dataIndex);
                },
              );
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: .center,
          children: [
            ...List.generate((totalData / itemsPerPage).ceil(), (index) {
              final isSelected = selectedPage == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    border: isSelected
                        ? const Border()
                        : Border.all(color: context.color.textColorDark),
                    color: isSelected
                        ? context.color.tertiaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
