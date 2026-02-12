import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInitial
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInProgress
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsSuccess
    extends GetSubscriptionPackageLimitsState {
  GetSubscriptionPackageLimitsSuccess({
    required this.error,
    required this.message,
    required this.hasSubscription,
  });
  final bool error;
  final String message;
  final bool hasSubscription;
}

class GetSubsctiptionPackageLimitsFailure
    extends GetSubscriptionPackageLimitsState {
  GetSubsctiptionPackageLimitsFailure(this.errorMessage);
  final String errorMessage;
}

class GetSubsctiptionPackageLimitsCubit
    extends Cubit<GetSubscriptionPackageLimitsState> {
  GetSubsctiptionPackageLimitsCubit()
      : super(GetSubscriptionPackageLimitsInitial());
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  Future<void> getLimits({required String packageType}) async {
    try {
      emit(GetSubscriptionPackageLimitsInProgress());
      final subscriptionPackageLimit =
          await _subscriptionRepository.getPackageLimit(
        limitType: packageType,
      );
      if (subscriptionPackageLimit['error'] == true) {
        emit(
          GetSubsctiptionPackageLimitsFailure(
            subscriptionPackageLimit['message']?.toString() ?? '',
          ),
        );
      } else {
        final data =
            subscriptionPackageLimit['data'] as Map<String, dynamic>? ?? {};
        final isPackageAvailable = data['package_available'] as bool? ?? false;
        final isFeatureAvailable = data['feature_available'] as bool? ?? false;
        final isLimitAvailable = data['limit_available'] as bool? ?? false;
        final pT = PackageType.values.firstWhere(
          (element) => element.value == packageType,
        );
        bool? hasSubscription;

        if (pT.checkLimit) {
          hasSubscription = isPackageAvailable && isLimitAvailable;
        } else if (pT.checkFeature) {
          hasSubscription = isPackageAvailable && isFeatureAvailable;
        } else {
          hasSubscription = isPackageAvailable;
        }
        emit(
          GetSubscriptionPackageLimitsSuccess(
            error: subscriptionPackageLimit['error'] as bool? ?? false,
            message: subscriptionPackageLimit['message']?.toString() ?? '',
            hasSubscription: hasSubscription,
          ),
        );
      }
    } on Exception catch (error) {
      emit(GetSubsctiptionPackageLimitsFailure(error.toString()));
    }
  }
}
