import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesInitial extends FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesInProgress
    extends FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesSuccess extends FetchSubscriptionPackagesState {
  FetchSubscriptionPackagesSuccess({
    required this.packageResponseModel,
    required this.isLoadingMore,
    required this.hasError,
    required this.offset,
    required this.total,
  });
  final PackageResponseModel packageResponseModel;
  final bool isLoadingMore;
  final bool hasError;
  final int offset;
  final int total;

  FetchSubscriptionPackagesSuccess copyWith({
    PackageResponseModel? packageResponseModel,
    bool? isLoadingMore,
    bool? hasError,
    int? offset,
    int? total,
  }) {
    return FetchSubscriptionPackagesSuccess(
      packageResponseModel: packageResponseModel ?? this.packageResponseModel,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchSubscriptionPackagesFailure extends FetchSubscriptionPackagesState {
  FetchSubscriptionPackagesFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchSubscriptionPackagesCubit
    extends Cubit<FetchSubscriptionPackagesState> {
  FetchSubscriptionPackagesCubit() : super(FetchSubscriptionPackagesInitial());
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();
  Future<void> fetchPackages() async {
    try {
      emit(FetchSubscriptionPackagesInProgress());
      final result = await _subscriptionRepository.getSubscriptionPackages(
        offset: 0,
      );
      emit(
        FetchSubscriptionPackagesSuccess(
          packageResponseModel: result,
          offset: 0,
          isLoadingMore: false,
          total: result.subscriptionPackage.length,
          hasError: false,
        ),
      );
    } on Exception catch (e) {
      emit(FetchSubscriptionPackagesFailure(e));
    }
  }

  bool hasMore() {
    if (state is FetchSubscriptionPackagesSuccess) {
      return (state as FetchSubscriptionPackagesSuccess)
              .packageResponseModel
              .subscriptionPackage
              .length <
          (state as FetchSubscriptionPackagesSuccess).total;
    }
    return false;
  }

  Future<void> fetchMorePackages() async {
    if (state is FetchSubscriptionPackagesInProgress) {
      return;
    }
    try {
      if (state is FetchSubscriptionPackagesSuccess) {
        emit(
          (state as FetchSubscriptionPackagesSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _subscriptionRepository.getSubscriptionPackages(
          offset: (state as FetchSubscriptionPackagesSuccess)
              .packageResponseModel
              .subscriptionPackage
              .length,
        );

        final subscriptionPacakges = (state as FetchSubscriptionPackagesSuccess)
            .packageResponseModel
            .subscriptionPackage
          ..addAll(result.subscriptionPackage);

        emit(
          FetchSubscriptionPackagesSuccess(
            packageResponseModel: result,
            isLoadingMore: false,
            hasError: false,
            offset: subscriptionPacakges.length,
            total: result.subscriptionPackage.length,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchSubscriptionPackagesSuccess)
            .copyWith(isLoadingMore: false, hasError: true),
      );
    }
  }
}
