import 'package:ebroker/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/cards/agent_project_card.dart';
// Import material.dart for ListView

class AgentProjects extends StatefulWidget {
  const AgentProjects({
    required this.agentId,
    required this.isAdmin,
    super.key,
  });

  final bool isAdmin;
  final String agentId;

  @override
  State<AgentProjects> createState() => _AgentProjectsState();
}

class _AgentProjectsState extends State<AgentProjects> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchAgentsProjectCubit, FetchAgentsProjectState>(
      builder: (context, state) {
        if (state is FetchAgentsProjectLoading) {
          return Center(
            child: UiUtils.progress(
              normalProgressColor: context.color.tertiaryColor,
            ),
          );
        }
        if (state is FetchAgentsProjectFailure) {
          return SomethingWentWrong(
            errorMessage: state.errorMessage.toString(),
          );
        }
        if (state is FetchAgentsProjectSuccess &&
            state.agentsProperty.projectData.isEmpty) {
          return Container(
            clipBehavior: .antiAlias,
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ),
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
              height: MediaQuery.of(context).size.height * 0.25,
              title: 'noProjectFound'.translate(context),
              description: 'noProjectFoundDescription'.translate(context),
              onTapRetry: () async {
                await context
                    .read<FetchAgentsProjectCubit>()
                    .fetchAgentsProject(
                      agentId: widget.agentId,
                      forceRefresh: true,
                      isAdmin: widget.isAdmin,
                    );
              },
            ),
          );
        }
        if (state is FetchAgentsProjectSuccess) {
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
              shrinkWrap: true, // Crucial for nested scrolling contexts
              physics:
                  const NeverScrollableScrollPhysics(), // Ensures parent scroll handles it
              itemCount:
                  state.agentsProperty.projectData.length +
                  (context.watch<FetchAgentsProjectCubit>().isLoadingMore()
                      ? 1
                      : 0), // Add 1 for loading indicator
              itemBuilder: (context, index) {
                if (index == state.agentsProperty.projectData.length) {
                  // This is the loading indicator item
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
                final agentsProject = state.agentsProperty.projectData[index];
                return AgentProjectCardBig(
                  project: agentsProject,
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
