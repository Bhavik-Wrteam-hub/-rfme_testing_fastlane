import 'package:ebroker/data/cubits/fetch_home_page_data_cubit.dart';
import 'package:ebroker/data/cubits/fetch_home_sections_data_cubit.dart';
import 'package:ebroker/data/cubits/fetch_other_sections_cubit.dart';
import 'package:ebroker/data/cubits/fetch_project_sections_cubit.dart';
import 'package:ebroker/data/cubits/fetch_property_sections_cubit.dart';
import 'package:ebroker/exports/main_export.dart';

/// Orchestrates homepage section API calls and injects their results into
/// `FetchHomePageDataCubit` (which acts as an aggregated view-model).
class HomeSections {
  static Future<void> fetchAllHomeSections(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    final home = context.read<FetchHomePageDataCubit>();
    final sectionsCubit = context.read<FetchHomeSectionsDataCubit>();
    final propertyCubit = context.read<FetchPropertySectionsCubit>();
    final projectCubit = context.read<FetchProjectSectionsCubit>();
    final otherCubit = context.read<FetchOtherSectionsCubit>();

    final futures = <Future<void>>[
      sectionsCubit.fetch(forceRefresh: forceRefresh).then((_) {
        final s = sectionsCubit.state;
        if (s is FetchHomeSectionsDataSuccess) {
          home.setSectionsOrder(s.data);
        }
      }),
      propertyCubit.fetch(forceRefresh: forceRefresh).then((_) {
        final s = propertyCubit.state;
        if (s is FetchPropertySectionsSuccess) {
          home.setPropertySections(s.data);
        }
      }),
      projectCubit.fetch(forceRefresh: forceRefresh).then((_) {
        final s = projectCubit.state;
        if (s is FetchProjectSectionsSuccess) {
          home.setProjectSections(s.data);
        }
      }),
      otherCubit.fetch(forceRefresh: forceRefresh).then((_) {
        final s = otherCubit.state;
        if (s is FetchOtherSectionsSuccess) {
          home.setOtherSections(s.data);
        }
      }),
    ];

    await Future.wait(futures);
  }
}
