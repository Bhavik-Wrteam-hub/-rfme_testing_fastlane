import 'package:ebroker/data/cubits/advertisement/fetch_ad_banners_cubit.dart';
import 'package:ebroker/data/cubits/agents/apply_agent_verification_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_agent_verification_form_fields.dart';
import 'package:ebroker/data/cubits/agents/fetch_agent_verification_form_values.dart';
import 'package:ebroker/data/cubits/agents/fetch_agents_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_project_by_agents_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_by_agent_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/cubits/appointment/delete/delete_extra_time_slot_cubit.dart';
import 'package:ebroker/data/cubits/appointment/delete/delete_unavailability_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/check_availability_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_agent_previous_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_agent_time_schedules_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_agent_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_booking_preferences_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_extra_time_slots_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_monthly_time_slots_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_unavailability_data_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_user_previous_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_user_reports_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_user_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/add_unavailability_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/create_appointment_request_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/manage_extra_time_slot_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/report_user_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/set_agent_time_schedule_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_agent_time_schedules_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_appointment_status_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_booking_preferences_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_meeting_type_cubit.dart';
import 'package:ebroker/data/cubits/auth/get_user_data_cubit.dart';
import 'package:ebroker/data/cubits/fetch_faqs_cubit.dart';
import 'package:ebroker/data/cubits/fetch_home_page_data_cubit.dart';
import 'package:ebroker/data/cubits/fetch_home_sections_data_cubit.dart';
import 'package:ebroker/data/cubits/fetch_other_sections_cubit.dart';
import 'package:ebroker/data/cubits/fetch_project_sections_cubit.dart';
import 'package:ebroker/data/cubits/fetch_properties_by_cities_cubit.dart';
import 'package:ebroker/data/cubits/fetch_property_sections_cubit.dart';
import 'package:ebroker/data/cubits/fetch_single_article_cubit.dart';
import 'package:ebroker/data/cubits/payment/payment_link_cubit.dart';
import 'package:ebroker/data/cubits/personalized/add_update_personalized_interest.dart';
import 'package:ebroker/data/cubits/project/change_project_status_cubit.dart';
import 'package:ebroker/data/cubits/project/fetch_my_promoted_projects.dart';
import 'package:ebroker/data/cubits/property/change_property_status_cubit.dart';
import 'package:ebroker/data/cubits/property/create_advertisement_cubit.dart';
import 'package:ebroker/data/cubits/property/delete_property_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/cubits/property/fetch_compare_properties_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_premium_properties_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_similar_properties_cubit.dart';
import 'package:ebroker/data/cubits/property/home_infinityscroll_cubit.dart';
import 'package:ebroker/data/cubits/utility/fetch_facilities_cubit.dart';
import 'package:ebroker/data/cubits/utility/mortgage_calculator_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:nested/nested.dart';

class RegisterCubits {
  List<SingleChildWidget> register() {
    return [
      BlocProvider(create: (context) => FetchAdBannersCubit()),
      BlocProvider(create: (context) => FetchPropertiesByCitiesCubit()),
      BlocProvider(create: (context) => DeletePropertyCubit()),
      BlocProvider(create: (context) => UpdateMeetingTypeCubit()),
      BlocProvider(create: (context) => FetchSingleArticleCubit()),
      BlocProvider(create: (context) => GetUserDataCubit()),
      BlocProvider(create: (context) => FetchPremiumPropertiesCubit()),
      BlocProvider(create: (context) => FetchComparePropertiesCubit()),
      BlocProvider(create: (context) => FetchSimilarPropertiesCubit()),
      BlocProvider(create: (context) => FetchMyPromotedProjectsCubit()),
      BlocProvider(create: (context) => ChangeProjectStatusCubit()),
      BlocProvider(create: (context) => ChangePropertyStatusCubit()),
      BlocProvider(create: (context) => FetchFacilitiesCubit()),
      BlocProvider(create: (context) => PaymentLinkCubit()),
      BlocProvider(create: (context) => CreateAdvertisementCubit()),
      BlocProvider(create: (context) => MortgageCalculatorCubit()),
      BlocProvider(
        create: (context) => FetchAgentVerificationFormFieldsCubit(),
      ),
      BlocProvider(create: (context) => ApplyAgentVerificationCubit()),
      BlocProvider(
        create: (context) => FetchAgentVerificationFormValuesCubit(),
      ),
      BlocProvider(create: (context) => DeleteMessageCubit()),
      BlocProvider(create: (context) => FetchMyPromotedPropertysCubit()),
      BlocProvider(create: (context) => LoadChatMessagesCubit()),
      BlocProvider(create: (context) => FetchFaqsCubit()),
      BlocProvider(create: (context) => FetchHomePageDataCubit()),
      BlocProvider(create: (context) => FetchHomeSectionsDataCubit()),
      BlocProvider(create: (context) => FetchPropertySectionsCubit()),
      BlocProvider(create: (context) => FetchProjectSectionsCubit()),
      BlocProvider(create: (context) => FetchOtherSectionsCubit()),
      BlocProvider(create: (context) => FetchProjectByAgentCubit()),
      BlocProvider(create: (context) => FetchPropertyByAgentCubit()),
      BlocProvider(create: (context) => FetchAgentsPropertyCubit()),
      BlocProvider(create: (context) => FetchAgentsProjectCubit()),
      BlocProvider(create: (context) => FetchAgentsCubit()),
      BlocProvider(create: (context) => AuthCubit()),
      BlocProvider(create: (context) => FetchMyProjectsListCubit()),
      BlocProvider(create: (context) => HomePageInfinityScrollCubit()),
      BlocProvider(create: (context) => LoginCubit()),
      BlocProvider(create: (context) => CompanyCubit()),
      BlocProvider(create: (context) => FetchCategoryCubit()),
      BlocProvider(create: (context) => SearchPropertyCubit()),
      BlocProvider(create: (context) => DeleteAccountCubit()),
      BlocProvider(create: (context) => ProfileSettingCubit()),
      BlocProvider(create: (context) => NotificationCubit()),
      BlocProvider(create: (context) => AppThemeCubit()),
      BlocProvider(create: (context) => AuthenticationCubit()),
      BlocProvider(create: (context) => FetchMyPropertiesCubit()),
      BlocProvider(create: (context) => FetchPropertyFromCategoryCubit()),
      BlocProvider(create: (context) => FetchNotificationsCubit()),
      BlocProvider(create: (context) => LanguageCubit()),
      BlocProvider(create: (context) => GooglePlaceAutocompleteCubit()),
      BlocProvider(create: (context) => FetchArticlesCubit()),
      BlocProvider(create: (context) => FetchSystemSettingsCubit()),
      BlocProvider(create: (context) => FavoriteIDsCubit()),
      BlocProvider(create: (context) => FetchPromotedPropertiesCubit()),
      BlocProvider(create: (context) => FetchMostViewedPropertiesCubit()),
      BlocProvider(create: (context) => FetchFavoritesCubit()),
      BlocProvider(create: (context) => CreatePropertyCubit()),
      BlocProvider(create: (context) => UserDetailsCubit()),
      BlocProvider(create: (context) => FetchLanguageCubit()),
      BlocProvider(create: (context) => UpdateLanguageCubit()),
      BlocProvider(create: (context) => LikedPropertiesCubit()),
      BlocProvider(create: (context) => EnquiryIdsLocalCubit()),
      BlocProvider(create: (context) => AddToFavoriteCubitCubit()),
      BlocProvider(create: (context) => FetchSubscriptionPackagesCubit()),
      BlocProvider(create: (context) => GetApiKeysCubit()),
      BlocProvider(create: (context) => FetchCityCategoryCubit()),
      BlocProvider(create: (context) => GetChatListCubit()),
      BlocProvider(create: (context) => FetchPropertyReportReasonsListCubit()),
      BlocProvider(create: (context) => FetchMostLikedPropertiesCubit()),
      BlocProvider(create: (context) => FetchNearbyPropertiesCubit()),
      BlocProvider(create: (context) => FetchOutdoorFacilityListCubit()),
      BlocProvider(create: (context) => PropertyEditCubit()),
      BlocProvider(create: (context) => FetchCityPropertyList()),
      BlocProvider(create: (context) => FetchPersonalizedPropertyList()),
      BlocProvider(create: (context) => AddUpdatePersonalizedInterest()),
      BlocProvider(create: (context) => GetSubsctiptionPackageLimitsCubit()),

      // Appointment Flow Cubits
      BlocProvider(create: (context) => FetchUserUpcomingAppointmentsCubit()),
      BlocProvider(create: (context) => FetchUserPreviousAppointmentsCubit()),
      BlocProvider(create: (context) => FetchAgentUpcomingAppointmentsCubit()),
      BlocProvider(create: (context) => FetchAgentPreviousAppointmentsCubit()),
      BlocProvider(create: (context) => FetchAgentTimeSchedulesCubit()),
      BlocProvider(create: (context) => FetchMonthlyTimeSlotsCubit()),
      BlocProvider(create: (context) => FetchExtraTimeSlotsCubit()),
      BlocProvider(create: (context) => FetchUnavailabilityDataCubit()),
      BlocProvider(create: (context) => FetchUserReportsCubit()),
      BlocProvider(create: (context) => FetchBookingPreferencesCubit()),
      BlocProvider(create: (context) => CreateAppointmentRequestCubit()),
      BlocProvider(create: (context) => UpdateAppointmentStatusCubit()),
      BlocProvider(create: (context) => SetAgentTimeScheduleCubit()),
      BlocProvider(create: (context) => UpdateBookingPreferencesCubit()),
      BlocProvider(create: (context) => ManageExtraTimeSlotCubit()),
      BlocProvider(create: (context) => AddUnavailabilityCubit()),
      BlocProvider(create: (context) => DeleteUnavailabilityCubit()),
      BlocProvider(create: (context) => DeleteExtraTimeSlotCubit()),
      BlocProvider(create: (context) => CheckAvailabilityCubit()),
      BlocProvider(create: (context) => ReportUserCubit()),
      BlocProvider(create: (context) => UpdateAgentTimeSchedulesCubit()),

      // AI Generation
      BlocProvider(create: (context) => GenerateAiContentCubit()),
    ];
  }
}
