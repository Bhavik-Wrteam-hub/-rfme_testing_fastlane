import 'package:ebroker/utils/admob/native_ad_manager.dart';

class CustomerData implements NativeAdWidgetContainer {
  const CustomerData({
    required this.id,
    required this.slugId,
    required this.name,
    required this.profile,
    required this.mobile,
    required this.email,
    required this.address,
    required this.city,
    required this.country,
    required this.state,
    required this.facebookId,
    required this.twitterId,
    required this.youtubeId,
    required this.instagramId,
    required this.aboutMe,
    required this.projectCount,
    required this.propertyCount,
    required this.isVerified,
    required this.propertiesSoldCount,
    required this.propertiesRentedCount,
    required this.isAppointmentAvailable,
  });

  CustomerData.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      slugId = json['slug_id']?.toString() ?? '',
      name = json['name']?.toString() ?? '',
      profile = json['profile']?.toString() ?? '',
      mobile = json['mobile']?.toString() ?? '',
      email = json['email']?.toString() ?? '',
      address = json['address']?.toString() ?? '',
      city = json['city']?.toString() ?? '',
      country = json['country']?.toString() ?? '',
      state = json['state']?.toString() ?? '',
      facebookId = json['facebook_id']?.toString() ?? '',
      twitterId = json['twitter_id']?.toString() ?? '',
      youtubeId = json['youtube_id']?.toString() ?? '',
      instagramId = json['instagram_id']?.toString() ?? '',
      aboutMe = json['about_me']?.toString() ?? '',
      projectCount = json['projects_count']?.toString() ?? '',
      propertyCount = json['property_count']?.toString() ?? '',
      propertiesSoldCount = json['properties_sold_count']?.toString() ?? '',
      propertiesRentedCount = json['properties_rented_count']?.toString() ?? '',
      isVerified = json['is_verify'] as bool? ?? false,
      isAppointmentAvailable =
          json['is_appointment_available'] as bool? ?? false;

  final int id;
  final String slugId;
  final String name;
  final String profile;
  final String mobile;
  final String email;
  final String? address;
  final String? city;
  final String? country;
  final String? state;
  final String? facebookId;
  final String? twitterId;
  final String? youtubeId;
  final String? instagramId;
  final String? aboutMe;
  final String? projectCount;
  final String? propertyCount;
  final String? propertiesSoldCount;
  final String? propertiesRentedCount;
  final bool? isAppointmentAvailable;
  final bool? isVerified;
}
