class CustomException implements Exception {
  CustomException([this._message]);
  final dynamic _message;

  @override
  String toString() {
    return '$_message';
  }
}

class FetchDataException extends CustomException {
  FetchDataException([super.message]);
}

class BadRequestException extends CustomException {
  BadRequestException([super.message]);
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([super.message]);
}

class VerificationException extends CustomException {
  VerificationException([super.message]);
}

class InvalidInputException extends CustomException {
  InvalidInputException([super.message]);
}
