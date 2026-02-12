import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/cards/agent_property_card.dart';

class AgentProperties extends StatefulWidget {
  const AgentProperties({
    required this.agentId,
    required this.isAdmin,
    super.key,
  });
  final bool isAdmin;
  final String agentId;

  @override
  State<AgentProperties> createState() => _AgentPropertiesState();
}

class _AgentPropertiesState extends State<AgentProperties> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchAgentsPropertyCubit, FetchAgentsPropertyState>(
      builder: (agentsContext, state) {
        if (state is FetchAgentsPropertyLoading) {
          return Center(child: UiUtils.progress());
        }
        if (state is FetchAgentsPropertySuccess &&
            state.agentsProperty.propertiesData.isEmpty) {
          return Container(
            clipBehavior: .antiAlias,
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              border: Border.all(
                color: context.color.borderColor,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: NoDataFound(
              title: 'noPropertiesFound'.translate(context),
              description: 'noPropertiesFoundForAgentDescription'.translate(
                context,
              ),
              height: MediaQuery.of(context).size.height * 0.25,
              onTapRetry: () async {
                await agentsContext
                    .read<FetchAgentsPropertyCubit>()
                    .fetchAgentsProperty(
                      agentId: widget.agentId,
                      forceRefresh: true,
                      isAdmin: widget.isAdmin,
                    );
              },
            ),
          );
        }
        if (state is FetchAgentsPropertySuccess &&
            state.agentsProperty.propertiesData.isNotEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              border: Border.all(color: context.color.borderColor),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            margin: EdgeInsets.only(
              left: 16.rw(context),
              right: 16.rw(context),
              bottom: 16.rh(context),
            ),
            padding: EdgeInsets.all(12.rw(context)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  state.agentsProperty.propertiesData.length +
                  (agentsContext
                          .watch<FetchAgentsPropertyCubit>()
                          .isLoadingMore()
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == state.agentsProperty.propertiesData.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: UiUtils.progress(
                        height: 24.rh(context),
                        width: 24.rw(context),
                      ),
                    ),
                  );
                }
                final agentsProperty =
                    state.agentsProperty.propertiesData[index];
                return AgentPropertyCard(
                  isSelected: false,
                  isSelectable: false,
                  agentPropertiesData: agentsProperty,
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
