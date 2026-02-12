import 'package:ebroker/exports/main_export.dart';

class CheckPackage {
  Future<bool> checkPackageAvailable({
    required PackageType packageType,
  }) async {
    final parameters = {
      'type': packageType.value,
    };

    final response = await Api.get(
      url: Api.apiCheckPackageLimit,
      queryParameters: parameters,
    );

    if (response['error'] == true) {
      return false;
    }
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final isPackageAvailable = data['package_available'] as bool? ?? false;
    final isFeatureAvailable = data['feature_available'] as bool? ?? false;
    final isLimitAvailable = data['limit_available'] as bool? ?? false;

    if (packageType.checkLimit) {
      return isPackageAvailable && isLimitAvailable;
    } else if (packageType.checkFeature) {
      return isPackageAvailable && isFeatureAvailable;
    }
    return isPackageAvailable;
  }
}

enum PackageType {
  propertyList('property_list', checkLimit: true),
  propertyFeature('property_feature', checkLimit: true),
  projectList('project_list', checkLimit: true),
  projectFeature('project_feature', checkLimit: true),
  mortgageCalculatorDetail('mortgage_calculator_detail', checkFeature: true),
  premiumProperties('premium_properties', checkFeature: true),
  projectAccess('project_access', checkFeature: true),
  ;

  const PackageType(
    this.value, {
    this.checkLimit = false,
    this.checkFeature = false,
  });

  final String value;
  final bool checkLimit;
  final bool checkFeature;
}
