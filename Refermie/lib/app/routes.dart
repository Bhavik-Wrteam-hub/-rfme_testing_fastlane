import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/advertisement/my_advertisment_screen.dart';
import 'package:ebroker/ui/screens/agents/agent_details_screen.dart';
import 'package:ebroker/ui/screens/agents/agent_list_screen.dart';
import 'package:ebroker/ui/screens/agents/agent_verification_form.dart';
import 'package:ebroker/ui/screens/appointment/configuration_screens/appointment_configuration_screen.dart';
import 'package:ebroker/ui/screens/appointment/my_appointments_screen.dart';
import 'package:ebroker/ui/screens/appointment/send_request_screens/appointment_flow.dart';
import 'package:ebroker/ui/screens/auth/email_registration_form.dart';
import 'package:ebroker/ui/screens/auth/otp_screen.dart';
import 'package:ebroker/ui/screens/auth/phone_registration_form.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/ui/screens/home/widgets/city_list_screen.dart';
import 'package:ebroker/ui/screens/proprties/widgets/compare_property_screen.dart';
import 'package:ebroker/ui/screens/settings/faqs_screen.dart';

class Routes {
  //private constructor
  Routes._();

  static const appointmentFlow = '/appointmentFlow';
  static const appointmentConfiguration = '/appointmentConfiguration';
  static const comparePropertiesScreen = '/comparePropertiesScreen';
  static const myAppointmentsScreen = '/myAppointmentsScreen';
  static const agentVerificationForm = '/agentVerificationForm';
  static const agentDetailsScreen = '/agentDetailsScreen';
  static const agentListScreen = '/agentListScreen';
  static const splash = '/';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const otpScreen = 'otpScreen';
  static const emailRegistrationForm = 'emailRegistrationForm';
  static const phoneRegistrationForm = 'phoneRegistrationForm';
  static const editProfile = 'editProfile';
  static const main = 'main';
  static const home = 'home_screen';
  static const addProperty = 'addProperty';
  static const waitingScreen = 'waitingScreen';
  static const categories = 'Categories';
  static const cityListScreen = 'cityListScreen';
  static const addresses = 'address';
  static const chooseAdrs = 'chooseAddress';
  static const propertiesList = 'propertiesList';
  static const propertyDetails = 'PropertyDetails';
  static const contactUs = 'ContactUs';
  static const profileSettings = 'profileSettings';
  static const myEnquiry = 'MyEnquiry';
  static const filterScreen = 'filterScreen';
  static const notificationPage = 'notificationpage';
  static const notificationDetailPage = 'notificationdetailpage';
  static const addPropertyScreenRoute = 'addPropertyScreenRoute';
  static const articlesScreenRoute = 'articlesScreenRoute';
  static const subscriptionPackageListRoute = 'subscriptionPackageListRoute';
  static const maintenanceMode = '/maintenanceMode';
  static const favoritesScreen = '/favoritescreen';
  static const articleDetailsScreenRoute = '/articleDetailsScreenRoute';
  static const areaConvertorScreen = '/areaCalculatorScreen';

  // static const mortgageCalculatorScreen = '/mortgageCalculatorScreen';
  static const languageListScreenRoute = '/languageListScreenRoute';
  static const searchScreenRoute = '/searchScreenRoute';
  static const chooseLocaitonMap = '/chooseLocationMap';
  static const propertyMapScreen = '/propertyMap';
  static const dashboard = '/dashboard';

  static const myAdvertisment = '/myAdvertisment';
  static const transactionHistory = '/transactionHistory';

  // static const nearbyAllProperties = '/nearbyAllProperties';
  static const personalizedPropertyScreen = '/personalizedPropertyScreen';
  static const allProjectsScreen = '/allProjectsScreen';
  static const faqsScreen = '/faqsScreen';

  ///Project section routes
  static const String addProjectDetails = '/addProjectDetails';
  static const String projectMetaDataScreens = '/projectMetaDataScreens';
  static const String manageFloorPlansScreen = '/manageFloorPlansScreen';

  ///Add property screens
  static const selectPropertyTypeScreen = '/selectPropertyType';
  static const addPropertyDetailsScreen = '/addPropertyDetailsScreen';
  static const setPropertyParametersScreen = '/setPropertyParametersScreen';
  static const selectOutdoorFacility = '/selectOutdoorFacility';

  ///View project
  static const projectDetailsScreen = '/projectDetailsScreen';
  static const myProjects = '/myProjects';

  //Sandbox[test]
  static const playground = 'playground';

  static String currentRoute = '';
  static String previousCustomerRoute = '';

  static Route<dynamic>? onGenerateRouted(RouteSettings routeSettings) {
    previousCustomerRoute = currentRoute;
    currentRoute = routeSettings.name ?? '';
    log('CURRENT ROUTE $currentRoute');

    if (_isDeepLink(currentRoute)) {
      return null;
    }

    if (currentRoute.contains('/link?')) {
      return null;
    }

    switch (routeSettings.name) {
      case '':
        break;

      case splash:
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      case onboarding:
        return CupertinoPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case home:
        return CupertinoPageRoute(
          builder: (context) => const HomeScreen(from: 'main'),
        );
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case otpScreen:
        return OtpScreen.route(routeSettings);
      case emailRegistrationForm:
        return EmailRegistrationForm.route(routeSettings);
      case phoneRegistrationForm:
        return PhoneRegistrationForm.route(routeSettings);
      case editProfile:
        return EditProfileScreen.route(routeSettings);
      case categories:
        return CategoryList.route(routeSettings);
      case cityListScreen:
        return CityListScreen.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);
      case propertiesList:
        return PropertiesList.route(routeSettings);
      case propertyDetails:
        return PropertyDetails.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case profileSettings:
        return ProfileSettings.route(routeSettings);
      case filterScreen:
        return FilterScreen.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);
      case chooseLocaitonMap:
        return ChooseLocationMap.route(routeSettings);
      case articlesScreenRoute:
        return ArticlesScreen.route(routeSettings);
      case areaConvertorScreen:
        return AreaCalculator.route(routeSettings);
      case articleDetailsScreenRoute:
        return ArticleDetails.route(routeSettings);
      case subscriptionPackageListRoute:
        return SubscriptionPackageListScreen.route(routeSettings);
      case favoritesScreen:
        return FavoritesScreen.route(routeSettings);
      case selectPropertyTypeScreen:
        return SelectPropertyType.route(routeSettings);
      case transactionHistory:
        return TransactionHistory.route(routeSettings);
      case myAdvertisment:
        return MyAdvertisementScreen.route(routeSettings);
      case personalizedPropertyScreen:
        return PersonalizedPropertyScreen.route(routeSettings);
      case addPropertyDetailsScreen:
        return AddPropertyDetails.route(routeSettings);
      case setPropertyParametersScreen:
        return SetProeprtyParametersScreen.route(routeSettings);
      case searchScreenRoute:
        return SearchScreen.route(routeSettings);
      case propertyMapScreen:
        return PropertyMapScreen.route(routeSettings);
      case selectOutdoorFacility:
        return SelectOutdoorFacility.route(routeSettings);
      case addProjectDetails:
        return AddProjectDetails.route(routeSettings);
      case projectMetaDataScreens:
        return ProjectMetaDetails.route(routeSettings);
      case projectDetailsScreen:
        return ProjectDetailsScreen.route(routeSettings);
      case manageFloorPlansScreen:
        return ManageFloorPlansScreen.route(routeSettings);
      case myProjects:
        return MyProjects.route(routeSettings);
      case allProjectsScreen:
        return AllProjectsScreen.route(routeSettings);
      case agentListScreen:
        return AgentListScreen.route(routeSettings);
      case agentDetailsScreen:
        return AgentDetailsScreen.route(routeSettings);
      case agentVerificationForm:
        return AgentVerificationForm.route(routeSettings);
      case faqsScreen:
        return FaqsScreen.route(routeSettings);
      case comparePropertiesScreen:
        return ComparePropertyScreen.route(routeSettings);
      case appointmentFlow:
        return AppointmentFlow.route(routeSettings);
      case appointmentConfiguration:
        return AppointmentConfigurationScreen.route(routeSettings);
      case myAppointmentsScreen:
        return MyAppointmentsScreen.route(routeSettings);
      default:
        return null;
    }
    return null;
  }

  static bool _isDeepLink(String route) {
    return route.contains('/property-details/') ||
        route.contains('/project-details/') ||
        route.contains('/agent-details/') ||
        route.contains('/article-details/');
  }
}
