import 'package:dio/dio.dart';
import 'package:ebroker/data/repositories/chat_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';

class SendMessageState {}

class SendMessageInitial extends SendMessageState {}

class SendMessageInProgress extends SendMessageState {}

class SendMessageSuccess extends SendMessageState {
  SendMessageSuccess({
    required this.messageId,
  });
  final int messageId;
}

class SendMessageFailed extends SendMessageState {
  SendMessageFailed(
    this.error,
  );
  final dynamic error;
}

class SendMessageCubit extends Cubit<SendMessageState> {
  SendMessageCubit() : super(SendMessageInitial());
  final ChatRepository _chatRepostiory = ChatRepository();
  Future<void> send({
    required String senderId,
    required String recieverId,
    required String message,
    required String proeprtyId,
    String? audio,
    String? attachment,
  }) async {
    try {
      emit(SendMessageInProgress());
      MultipartFile? audioFile;
      MultipartFile? attachmentFile;
      final setMediaType = MediaType('audio', 'm4a');
      if (audio != null) {
        audioFile =
            await MultipartFile.fromFile(audio, contentType: setMediaType);
      }
      if (attachment != null) {
        attachmentFile = await MultipartFile.fromFile(attachment);
      }

      ///If use is not uploading any text so we will upload [File].
      var message0 = message;
      if (attachment != null && message == '') {
        message0 = '';
      }

      final result = await _chatRepostiory.sendMessage(
        senderId: senderId,
        recieverId: recieverId,
        message: message0,
        proeprtyId: proeprtyId,
        attachment: attachmentFile,
        audio: audioFile,
      );

      emit(SendMessageSuccess(messageId: int.parse(result['id'].toString())));
    } on ApiException catch (e) {
      emit(SendMessageFailed(e.toString()));
    }
  }
}
