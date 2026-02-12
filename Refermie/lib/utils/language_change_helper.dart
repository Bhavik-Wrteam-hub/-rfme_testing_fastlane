import 'dart:async';

import 'package:ebroker/data/cubits/category/fetch_category_cubit.dart';
import 'package:ebroker/data/cubits/chat_cubits/get_chat_users.dart';
import 'package:ebroker/data/cubits/outdoorfacility/fetch_outdoor_facility_list.dart';
import 'package:ebroker/data/cubits/project/fetch_my_projects_list_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:ebroker/data/cubits/property/home_infinityscroll_cubit.dart';
import 'package:ebroker/data/cubits/property/report/fetch_property_report_reason_list.dart';
import 'package:ebroker/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:ebroker/ui/screens/home/home_sections.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageChangeHelper {
  static void refreshAppData(BuildContext context) {
    unawaited(
      HomeSections.fetchAllHomeSections(
        context,
        forceRefresh: true,
      ),
    );
    unawaited(
      context.read<FetchSystemSettingsCubit>().fetchSettings(
        isAnonymous: HiveUtils.isUserAuthenticated(),
      ),
    );
    unawaited(context.read<HomePageInfinityScrollCubit>().fetch());
    unawaited(
      context.read<FetchCategoryCubit>().fetchCategories(forceRefresh: true),
    );
    unawaited(context.read<FetchOutdoorFacilityListCubit>().fetch());
    unawaited(context.read<GetChatListCubit>().fetch(forceRefresh: true));
    unawaited(
      context.read<FetchMyPropertiesCubit>().fetchMyProperties(
        type: '',
        status: '',
      ),
    );
    unawaited(context.read<FetchMyProjectsListCubit>().fetchMyProjects());
    unawaited(
      context.read<FetchPropertyReportReasonsListCubit>().fetch(
        forceRefresh: true,
      ),
    );
  }
}
