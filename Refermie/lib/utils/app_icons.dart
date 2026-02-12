/// Centralized icon path management for the application
class AppIcons {
  AppIcons._();

  static const String _basePath = 'assets/';
  static const String _svgPath = 'svg/';
  static const String _multiColorPath = 'svg/MultiColorSvg/';
  static const String _fallbackPath = 'svg/Fallback/';
  static const String _socialMediaPath = 'svg/social_media/';
  static const String _appIconPath = 'app_icons/';

  // Placeholder icons (consider removing if unused)
  static const String placeHolder = '';
  static const String ads = '';
  static const String propertyLimites = '';
  static final String citySectionTitleImage = _asset('city.jpg');

  // Payment methods
  static final String stripe = _asset('${_svgPath}stripe.svg');
  static final String bankTransfer = _asset('${_svgPath}bank.svg');
  static final String flutterwave = _asset('${_svgPath}flutterwave.svg');
  static final String paystack = _asset('${_svgPath}paystack.svg');
  static final String razorpay = _asset('${_svgPath}razorpay.svg');
  static final String paypal = _asset('${_svgPath}paypal.svg');

  // Feature icons
  static final String advertisementFeature = _asset(
    '${_svgPath}advertise_feature.svg',
  );
  static final String listingFeature = _asset('${_svgPath}listing_feature.svg');
  static final String featureAvailable = _asset(
    '${_svgPath}feature_available.svg',
  );
  static final String featureNotAvailable = _asset(
    '${_svgPath}feature_not_available.svg',
  );
  static final String info = _asset('${_svgPath}info.svg');
  static final String changeStatus = _asset('${_svgPath}change_status.svg');
  static final String interestedUsers = _asset(
    '${_svgPath}interested_users.svg',
  );
  static final String shareIcon = _asset('${_svgPath}share_icon.svg');
  static final String premium = _asset('${_svgPath}premium.svg');
  static final String sparkles = _asset('${_svgPath}sparkles.svg');

  // Authentication & UI
  static final String apple = _asset('${_svgPath}apple.svg');
  static final String google = _asset('${_svgPath}google.svg');

  // Navigation & Core UI
  static final String home = _asset('${_svgPath}home.svg');
  static final String homeActive = _asset('${_svgPath}home_active.svg');
  static final String profile = _asset('${_svgPath}profile.svg');
  static final String profileOutlined = _asset(
    '${_svgPath}profile_outlined.svg',
  );
  static final String profileActive = _asset('${_svgPath}profile_active.svg');
  static final String search = _asset('${_svgPath}search.svg');
  static final String closeCircle = _asset('${_svgPath}close_circle.svg');
  static final String properties = _asset('${_svgPath}properties.svg');
  static final String propertiesActive = _asset(
    '${_svgPath}properties_active.svg',
  );
  static final String chat = _asset('${_svgPath}chat.svg');
  static final String chatActive = _asset('${_svgPath}chat_active.svg');
  static final String notification = _asset('${_svgPath}notification.svg');
  static final String documentDownload = _asset(
    '${_svgPath}document_download.svg',
  );

  // Actions & Controls
  static final String iconArrowLeft = _asset('${_svgPath}icon_arrow_left.svg');
  static final String arrowLeft = _asset('${_svgPath}arrow_left.svg');
  static final String arrowRight = _asset('${_svgPath}arrow_right.svg');
  static final String downArrow = _asset('${_svgPath}down_arrow.svg');
  static final String filter = _asset('${_svgPath}filter.svg');
  static final String edit = _asset('${_svgPath}edit.svg');
  static final String bin = _asset('${_svgPath}bin.svg');
  static final String update = _asset('${_svgPath}update.svg');

  // Location & Map
  static final String location = _asset('${_svgPath}location.svg');
  static final String locationRound = _asset('${_svgPath}location_round.svg');
  static final String locationPin = _asset('${_svgPath}location_pin.svg');
  static final String propertyMap = _asset('${_svgPath}propertymap.svg');

  // Favorites & Interaction
  static final String heart = _asset('${_svgPath}heart.svg');
  static final String heartFilled = _asset('${_svgPath}heart_filled.svg');
  static final String interested = _asset('${_svgPath}interested.svg');

  // Communication
  static final String call = _asset('${_svgPath}call.svg');
  static final String callFilled = _asset('${_svgPath}call_filled.svg');
  static final String phone = _asset('${_svgPath}phone.svg');
  static final String email = _asset('${_svgPath}email.svg');
  static final String message = _asset('${_svgPath}message.svg');
  static final String paperClip = _asset('${_svgPath}paper_clip.svg');
  static final String mic = _asset('${_svgPath}mic.svg');
  static final String send = _asset('${_svgPath}send.svg');

  // Settings & Account
  static final String language = _asset('${_svgPath}language.svg');
  static final String darkTheme = _asset('${_svgPath}dark_theme.svg');
  static final String subscription = _asset('${_svgPath}subscription.svg');
  static final String shareApp = _asset('${_svgPath}share.svg');
  static final String rateUs = _asset('${_svgPath}rate_us.svg');
  static final String contactUs = _asset('${_svgPath}contact_us.svg');
  static final String aboutUs = _asset('${_svgPath}about_us.svg');
  static final String terms = _asset('${_svgPath}t_c.svg');
  static final String privacy = _asset('${_svgPath}privacypolicy.svg');
  static final String delete = _asset('${_svgPath}delete_account.svg');
  static final String logout = _asset('${_svgPath}logout.svg');
  static final String eye = _asset('${_svgPath}eye.svg');
  static final String eyeSlash = _asset('${_svgPath}eye_slash.svg');

  // Utility & Tools
  static final String calculator = _asset('${_svgPath}calculator.svg');
  static final String areaConvertor = _asset('${_svgPath}area_convertor.svg');
  static final String articles = _asset('${_svgPath}article.svg');
  static final String magic = _asset('${_svgPath}magic.svg');
  static final String faqs = _asset('${_svgPath}question_mark.svg');
  static final String calendar = _asset('${_svgPath}calendar.svg');
  static final String days = _asset('${_svgPath}days.svg');
  static final String transaction = _asset('${_svgPath}transaction.svg');
  static final String lock = _asset('${_svgPath}lock.svg');

  // Status & Badges
  static final String agentBadge = _asset('${_svgPath}agent_badge.svg');
  static final String promoted = _asset('${_svgPath}promoted.svg');
  static final String warning = _asset('${_svgPath}warning.svg');
  static final String report = _asset('${_svgPath}report.svg');
  static final String reportDark = _asset('${_svgPath}report_dark.svg');
  static final String featuredBolt = _asset('${_svgPath}featured_bolt.svg');
  static final String verified = _asset('${_svgPath}verified.svg');
  static final String meeting = _asset('${_svgPath}meeting.svg');
  static final String clock = _asset('${_svgPath}clock.svg');
  static final String userAdd = _asset('${_svgPath}user_add.svg');
  static final String videoCall = _asset('${_svgPath}video.svg');
  static final String appointment = _asset('${_svgPath}appointment.svg');
  static final String myAppointments = _asset('${_svgPath}my_appointments.svg');
  static final String bookings = _asset('${_svgPath}bookings.svg');
  static final String configuration = _asset('${_svgPath}configuration.svg');

  // Property specific
  static final String forRent = _asset('${_svgPath}for_rent.svg');
  static final String forSale = _asset('${_svgPath}for_sale.svg');
  static final String v360Degree = _asset('${_svgPath}v360.svg');

  // Project management
  static final String propertiesIcon = _asset('${_svgPath}properties_icon.svg');
  static final String upcomingProject = _asset(
    '${_svgPath}upcoming_projects_icon.svg',
  );
  static final String plusButtonIcon = _asset('${_svgPath}plus_btn.svg');
  static final String addButtonShape = _asset('${_svgPath}add_shape.svg');
  static final String myProjects = _asset('${_svgPath}my_projects.svg');

  // Company branding
  static final String splashLogo = _asset('${_appIconPath}splash_logo.png');
  static final String companyLogo = _asset('${_appIconPath}company_logo.svg');
  static final String defaultPersonLogo = _asset(
    '${_svgPath}defaultProfileIcon.svg',
  );

  // Multi-color illustrations
  static final String somethingWentWrong = _asset(
    '${_multiColorPath}something_went_wrong.svg',
  );
  static final String propertySubmitted = _asset(
    '${_multiColorPath}propertysubmited.svg',
  );
  static final String noChatFound = _asset(
    '${_multiColorPath}no_chat_found.svg',
  );
  static final String noDataFound = _asset(
    '${_multiColorPath}no_data_found_illustrator.svg',
  );
  static final String noInternet = _asset(
    '${_multiColorPath}no_internet_illustrator.svg',
  );
  static final String deleteIllustration = _asset(
    '${_multiColorPath}delete_illustrator.svg',
  );
  static final String logoutIllustration = _asset(
    '${_multiColorPath}logout_illustrator.svg',
  );
  static final String deleteGirl = _asset('${_svgPath}delete.svg');

  // Fallback icons
  static final String fallbackSplashLogo = _asset('${_fallbackPath}splash.svg');
  static final String fallbackPlaceholderLogo = _asset(
    '${_fallbackPath}placeholder.svg',
  );
  static final String fallbackHomeLogo = _asset('${_fallbackPath}homeLogo.svg');

  // Onboarding
  static final String onBoardingOne = _asset('${_svgPath}onbo_a.svg');
  static final String onBoardingTwo = _asset('${_svgPath}onbo_b.svg');
  static final String onBoardingThree = _asset('${_svgPath}onbo_c.svg');

  // Social media
  static final String facebook = _asset('${_socialMediaPath}Facebook.svg');
  static final String twitter = _asset('${_socialMediaPath}Twitter.svg');
  static final String instagram = _asset('${_socialMediaPath}Insta.svg');
  static final String youtube = _asset('${_socialMediaPath}Youtube.svg');

  // Helper method
  static String _asset(String path) => '$_basePath$path';
}
