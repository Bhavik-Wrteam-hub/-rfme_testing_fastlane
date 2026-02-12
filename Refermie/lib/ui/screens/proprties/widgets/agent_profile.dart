import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgentProfileWidget extends StatefulWidget {
  const AgentProfileWidget({
    required this.addedBy,
    required this.profileImage,
    required this.name,
    required this.isVerified,
    required this.email,
    required this.propertiesCount,
    required this.projectsCount,
    super.key,
  });
  final String addedBy;
  final String profileImage;
  final String name;
  final bool isVerified;
  final String email;
  final String propertiesCount;
  final String projectsCount;

  @override
  State<AgentProfileWidget> createState() => _AgentProfileWidgetState();
}

class _AgentProfileWidgetState extends State<AgentProfileWidget> {
  bool? isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.addedBy == '0';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchAgentsPropertyCubit, FetchAgentsPropertyState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () async {
              try {
                await Navigator.pushNamed(
                  context,
                  Routes.agentDetailsScreen,
                  arguments: {
                    'agentID': widget.addedBy,
                    'isAdmin': isAdmin,
                  },
                );
              } on Exception catch (_) {}
            },
            child: Row(
              children: [
                Container(
                  width: 40.rw(context),
                  height: 40.rh(context),
                  clipBehavior: .antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomImage(
                    imageUrl: widget.profileImage,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        mainAxisSize: .min,
                        children: [
                          CustomText(
                            widget.name,
                            fontWeight: .w500,
                            fontSize: context.font.sm,
                          ),
                          if (widget.isVerified)
                            Container(
                              margin: const EdgeInsetsDirectional.only(
                                start: 4,
                              ),
                              alignment: Alignment.center,
                              child: CustomImage(
                                imageUrl: AppIcons.verified,
                                height: 18.rh(context),
                                width: 18.rw(context),
                                color: Colors.blueAccent,
                              ),
                            ),
                        ],
                      ),
                      CustomText(
                        widget.email,
                        fontSize: context.font.xs,
                        color: context.color.textColorDark,
                        maxLines: 1,
                        fontWeight: .w400,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: context.color.textColorDark.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: .center,
                          children: [
                            if (widget.propertiesCount != '0' ||
                                widget.propertiesCount.isNotEmpty) ...[
                              Expanded(
                                child: CustomText(
                                  '${'properties'.translate(context)}: ${widget.propertiesCount}',
                                  fontSize: context.font.xs,
                                  color: context.color.textColorDark,
                                  maxLines: 1,
                                  textAlign: .center,
                                  fontWeight: .w400,
                                ),
                              ),
                              if (widget.projectsCount != '0' ||
                                  widget.projectsCount.isNotEmpty) ...[
                                Container(
                                  height: 12,
                                  width: 1,
                                  color: context.color.textLightColor
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ],
                            if (widget.projectsCount != '0' ||
                                widget.projectsCount.isNotEmpty) ...[
                              Expanded(
                                child: CustomText(
                                  '${'projects'.translate(context)}: ${widget.projectsCount}',
                                  fontSize: context.font.xs,
                                  color: context.color.textColorDark,
                                  maxLines: 1,
                                  textAlign: .center,
                                  fontWeight: .w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
