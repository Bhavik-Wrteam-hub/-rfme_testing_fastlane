import 'package:flutter_bloc/flutter_bloc.dart';

class EnquiryIdsLocalCubit extends Cubit<EnquiryIdsLocalState> {
  EnquiryIdsLocalCubit() : super(EnquiryIdsLocalState(ids: []));

  void add(dynamic id) {
    final ids = state.ids;
    ids?.add(
      id,
    );
    emit(
      EnquiryIdsLocalState(ids: ids),
    );
  }
}

class EnquiryIdsLocalState {
  EnquiryIdsLocalState({
    this.ids,
  });
  List<dynamic>? ids;

  EnquiryIdsLocalState copyWith({
    List<dynamic>? ids,
  }) {
    return EnquiryIdsLocalState(
      ids: ids ?? this.ids,
    );
  }

  @override
  String toString() => 'EnquiryIdsLocalState(ids: $ids)';
}
