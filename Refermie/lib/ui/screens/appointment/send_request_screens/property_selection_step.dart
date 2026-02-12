import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/properties_data.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/cards/agent_property_card.dart';
import 'package:flutter/material.dart';

class PropertySelectionStep extends StatefulWidget {
  const PropertySelectionStep({
    required this.selectedProperty,
    required this.onPropertySelected,
    required this.agentId,
    required this.isAdmin,
    super.key,
  });

  final PropertiesData? selectedProperty;
  final ValueChanged<PropertiesData> onPropertySelected;
  final String agentId;
  final bool isAdmin;

  @override
  State<PropertySelectionStep> createState() => _PropertySelectionStepState();
}

class _PropertySelectionStepState extends State<PropertySelectionStep> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _scrollController = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_scrollController.isEndReached()) {
      if (context.read<FetchAgentsPropertyCubit>().hasMoreData()) {
        await context.read<FetchAgentsPropertyCubit>().fetchMore(
          isAdmin: widget.isAdmin,
        );
      }
    }
  }

  Future<void> _onSearchChanged() async {
    // Search functionality not implemented for agent properties
    await context.read<FetchAgentsPropertyCubit>().searchAgentsProperties(
      agentId: widget.agentId,
      isAdmin: widget.isAdmin,
      searchQuery: _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchAgentsPropertyCubit, FetchAgentsPropertyState>(
      builder: (context, state) {
        if (state is FetchAgentsPropertySuccess) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SearchBar(searchController: _searchController),
                const SizedBox(height: 16),
                ...state.agentsProperty.propertiesData.map(
                  (property) => AgentPropertyCard(
                    agentPropertiesData: property,
                    isSelected: property == widget.selectedProperty,
                    isSelectable: true,
                    onTap: () => widget.onPropertySelected(property),
                  ),
                ),
                // Show loading indicator when paginating
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            ),
          );
        } else if (state is FetchAgentsPropertyLoading) {
          return Center(child: UiUtils.progress());
        } else if (state is FetchAgentsPropertyFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                SomethingWentWrong(
                  errorMessage: state.errorMessage.toString(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Retry loading properties
                    await context
                        .read<FetchAgentsPropertyCubit>()
                        .fetchAgentsProperty(
                          forceRefresh: true,
                          agentId: widget.agentId,
                          isAdmin: widget.isAdmin,
                        );
                  },
                  child: CustomText('retry'.translate(context)),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Center(
            child: UiUtils.progress(
              height: 22.rh(context),
              width: 22.rw(context),
            ),
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: .center,
      crossAxisAlignment: .start,
      children: [
        Expanded(
          child: SizedBox(
            height: 48.rh(context),
            child: CustomTextFormField(
              borderRadius: 8,
              borderColor: context.color.borderColor,
              controller: searchController,
              fillColor: Theme.of(context).colorScheme.secondaryColor,
              hintText: 'searchHintLbl'.translate(context),
              prefix: _setSearchIcon(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _setSearchIcon(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: 8,
        left: 8,
        top: 8.rs(context),
        bottom: 8.rs(context),
      ),
      child: CustomImage(
        imageUrl: AppIcons.search,
        color: context.color.textColorDark,
        width: 22.rw(context),
        height: 22.rh(context),
      ),
    );
  }
}
