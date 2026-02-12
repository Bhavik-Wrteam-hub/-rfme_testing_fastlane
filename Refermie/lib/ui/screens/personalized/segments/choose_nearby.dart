part of '../personalized_property_screen.dart';

class NearbyInterest extends StatefulWidget {
  const NearbyInterest({
    required this.controller,
    required this.onInteraction,
    required this.type,
    super.key,
  });

  final PageController controller;

  final PersonalizedVisitType type;
  final dynamic Function(List<int> selectedNearbyPlacesIds) onInteraction;

  @override
  State<NearbyInterest> createState() => _NearbyInterestState();
}

class _NearbyInterestState extends State<NearbyInterest>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedIds = personalizedInterestSettings.outdoorFacilityIds;

  @override
  void initState() {
    unawaited(context.read<FetchOutdoorFacilityListCubit>().fetchIfFailed());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isFirstTime = widget.type == PersonalizedVisitType.firstTime;
    final facilityList = context
        .watch<FetchOutdoorFacilityListCubit>()
        .getList();
    final facilityLength = facilityList.length;
    final state = context.watch<FetchOutdoorFacilityListCubit>().state;
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
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            CustomText(
              'chooseNearbyPlaces'.translate(context),
              fontSize: context.font.md,
              color: context.color.textColorDark,
              fontWeight: .w500,
            ),
            const SizedBox(height: 6),
            CustomText(
              'getRecommandation'.translate(context),
              fontSize: context.font.xs,
              color: context.color.textColorDark,
            ),
            const SizedBox(
              height: 24,
            ),
            if (state is FetchOutdoorFacilityListInProgress) ...{
              UiUtils.progress(),
            },
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: facilityLength,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                physics: Constant.scrollPhysics,
                itemBuilder: (BuildContext context, int index) {
                  final facility = facilityList[index];
                  final isSelected = selectedIds.contains(facility.id);
                  return GestureDetector(
                    onTap: () {
                      selectedIds.addOrRemove(facility.id!);
                      widget.onInteraction.call(selectedIds);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 1,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.color.tertiaryColor
                              : context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: context.color.borderColor),
                        ),
                        height: 85.rh(context),
                        width: 108.rw(context),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            SizedBox(
                              height: 24.rh(context),
                              width: 24.rw(context),
                              child: CustomImage(
                                imageUrl: facility.image ?? '',
                                color: isSelected
                                    ? context.color.buttonColor
                                    : context.color.textColorDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomText(
                              facility.translatedName ?? facility.name ?? '',
                              color: selectedIds.contains(facility.id)
                                  ? context.color.buttonColor
                                  : context.color.textColorDark,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
