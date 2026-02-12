import 'package:ebroker/data/model/ad_banner_model.dart';
import 'package:ebroker/data/repositories/ad_banners_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class FetchAdBannersState {}

class FetchAdBannersInitial extends FetchAdBannersState {}

class FetchAdBannersLoading extends FetchAdBannersState {}

class FetchAdBannersSuccess extends FetchAdBannersState {
  FetchAdBannersSuccess({required this.banners});
  final List<AdBanner> banners;
}

class FetchAdBannersFailure extends FetchAdBannersState {
  FetchAdBannersFailure(this.errorMessage);
  final dynamic errorMessage;
}

// Cubit
class FetchAdBannersCubit extends Cubit<FetchAdBannersState> {
  FetchAdBannersCubit() : super(FetchAdBannersInitial());

  final AdBannersRepository _repository = AdBannersRepository();

  Future<void> fetch({
    required String page, // homepage || property_detail
  }) async {
    try {
      emit(FetchAdBannersLoading());
      final banners = await _repository.fetchAdBanners(page: page);
      emit(FetchAdBannersSuccess(banners: banners));
    } on ApiException catch (e) {
      emit(FetchAdBannersFailure(e));
    } on Exception catch (e) {
      emit(FetchAdBannersFailure(e.toString()));
    }
  }
}
