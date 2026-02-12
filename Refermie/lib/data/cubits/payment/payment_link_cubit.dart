import 'package:ebroker/data/repositories/payment_link_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PaymentLinkState {}

class PaymentLinkInitial extends PaymentLinkState {}

class PaymentLinkLoading extends PaymentLinkState {}

class PaymentLinkSuccess extends PaymentLinkState {
  PaymentLinkSuccess({
    required this.gateway,
    required this.link,
  });

  final String gateway;
  final String link;
}

class PaymentLinkFailure extends PaymentLinkState {
  PaymentLinkFailure(this.error);
  final dynamic error;
}

class PaymentLinkCubit extends Cubit<PaymentLinkState> {
  PaymentLinkCubit({PaymentLinkRepository? repository})
    : _repository = repository ?? PaymentLinkRepository(),
      super(PaymentLinkInitial());

  final PaymentLinkRepository _repository;

  Future<String?> fetchLink({
    required int packageId,
    required String gateway,
    double? amount,
  }) async {
    emit(PaymentLinkLoading());
    try {
      final link = await _repository.fetchPaymentLink(
        packageId: packageId,
        gateway: gateway,
        amount: amount,
      );
      emit(
        PaymentLinkSuccess(
          gateway: gateway,
          link: link,
        ),
      );
      return link;
    } on Exception catch (e) {
      emit(PaymentLinkFailure(e.toString()));
      return null;
    }
  }

  void clear() {
    emit(PaymentLinkInitial());
  }
}
