import 'package:ebroker/data/repositories/interest_repository.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PropertyInterest {
  interested('1'),
  notInterested('0');

  const PropertyInterest(this.value);
  final String value;
}

abstract class ChangeInterestInPropertyState {}

class ChangeInterestInPropertyInitial extends ChangeInterestInPropertyState {}

class ChangeInterestInPropertyInProgress
    extends ChangeInterestInPropertyState {}

class ChangeInterestInPropertySuccess extends ChangeInterestInPropertyState {
  ChangeInterestInPropertySuccess({
    required this.interest,
  });
  PropertyInterest interest;
}

class ChangeInterestInPropertyFailure extends ChangeInterestInPropertyState {
  ChangeInterestInPropertyFailure(this.errorMessage);
  final String errorMessage;
}

class ChangeInterestInPropertyCubit
    extends Cubit<ChangeInterestInPropertyState> {
  ChangeInterestInPropertyCubit() : super(ChangeInterestInPropertyInitial());
  final InterestRepository _interestRepository = InterestRepository();

  Future<void> changeInterest({
    required String propertyId,
    required PropertyInterest interest,
  }) async {
    try {
      emit(ChangeInterestInPropertyInProgress());
      await _interestRepository.setInterest(
        interest: interest.value,
        propertyId: propertyId,
      );
      if (interest == PropertyInterest.interested) {
        Constant.interestedPropertyIds.add(int.parse(propertyId));
      } else {
        Constant.interestedPropertyIds.remove(int.parse(propertyId));
      }

      emit(ChangeInterestInPropertySuccess(interest: interest));
    } on Exception catch (e) {
      emit(ChangeInterestInPropertyFailure(e.toString()));
    }
  }
}
