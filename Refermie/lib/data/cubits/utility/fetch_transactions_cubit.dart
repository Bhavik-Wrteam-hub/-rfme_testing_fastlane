import 'dart:developer';

import 'package:ebroker/data/model/transaction_model.dart';
import 'package:ebroker/data/repositories/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchTransactionsState {}

class FetchTransactionsInitial extends FetchTransactionsState {}

class FetchTransactionsInProgress extends FetchTransactionsState {}

class FetchTransactionsSuccess extends FetchTransactionsState {
  FetchTransactionsSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.transactionmodel,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<TransactionModel> transactionmodel;
  final int offset;
  final int total;

  FetchTransactionsSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<TransactionModel>? transactionmodel,
    int? offset,
    int? total,
  }) {
    return FetchTransactionsSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      transactionmodel: transactionmodel ?? this.transactionmodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchTransactionsFailure extends FetchTransactionsState {
  FetchTransactionsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchTransactionsCubit extends Cubit<FetchTransactionsState> {
  FetchTransactionsCubit() : super(FetchTransactionsInitial());

  final TransactionRepository _transactionRepository = TransactionRepository();

  Future<void> fetchTransactions() async {
    try {
      emit(FetchTransactionsInProgress());

      final result = await _transactionRepository.fetchTransactions(
        offset: 0,
      );

      emit(
        FetchTransactionsSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          transactionmodel: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } on Exception catch (e, stackTrace) {
      if (!isClosed) {
        log(stackTrace.toString());
        emit(FetchTransactionsFailure(e));
      }
    }
  }

  Future<void> fetchTransactionsMore() async {
    try {
      if (state is FetchTransactionsSuccess) {
        if ((state as FetchTransactionsSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchTransactionsSuccess).copyWith(isLoadingMore: true));
        final result = await _transactionRepository.fetchTransactions(
          offset: (state as FetchTransactionsSuccess).transactionmodel.length,
        );

        final transactionmodelState = state as FetchTransactionsSuccess;
        transactionmodelState.transactionmodel.addAll(result.modelList);
        emit(
          FetchTransactionsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            transactionmodel: transactionmodelState.transactionmodel,
            offset: (state as FetchTransactionsSuccess).transactionmodel.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchTransactionsSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  bool isLoadingMore() {
    if (state is FetchTransactionsSuccess) {
      return (state as FetchTransactionsSuccess).isLoadingMore;
    }
    return false;
  }

  bool hasMoreData() {
    if (state is FetchTransactionsSuccess) {
      return (state as FetchTransactionsSuccess).transactionmodel.length <
          (state as FetchTransactionsSuccess).total;
    }
    return false;
  }
}
