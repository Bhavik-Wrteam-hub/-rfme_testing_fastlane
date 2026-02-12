import 'package:ebroker/data/repositories/chat_repository.dart';
import 'package:ebroker/ui/screens/chat/model/chat_message_model.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadChatMessagesState {}

class LoadChatMessagesInitial extends LoadChatMessagesState {}

class LoadChatMessagesInProgress extends LoadChatMessagesState {}

class LoadChatMessagesSuccess extends LoadChatMessagesState {
  LoadChatMessagesSuccess({
    required this.messages,
    required this.isBlockedByMe,
    required this.isBlockedByUser,
    required this.currentPage,
    required this.userId,
    required this.propertyId,
    required this.totalPage,
    required this.isLoadingMore,
  });
  List<ChatMessage> messages;
  bool isBlockedByMe;
  bool isBlockedByUser;
  int currentPage;
  int userId;
  int propertyId;
  int totalPage;
  bool isLoadingMore;

  LoadChatMessagesSuccess copyWith({
    List<ChatMessage>? messages,
    bool? isBlockedByMe,
    bool? isBlockedByUser,
    int? currentPage,
    int? userId,
    int? propertyId,
    int? totalPage,
    bool? isLoadingMore,
  }) {
    return LoadChatMessagesSuccess(
      messages: messages ?? this.messages,
      isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
      isBlockedByUser: isBlockedByUser ?? this.isBlockedByUser,
      currentPage: currentPage ?? this.currentPage,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      totalPage: totalPage ?? this.totalPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  String toString() {
    return '''LoadChatMessagesSuccess(messages: $messages, isBlockedByMe: $isBlockedByMe, isBlockedByUser: $isBlockedByUser, currentPage: $currentPage, userId: $userId, propertyId: $propertyId, totalPage: $totalPage, isLoadingMore: $isLoadingMore)''';
  }
}

class LoadChatMessagesFailed extends LoadChatMessagesState {
  LoadChatMessagesFailed({
    required this.error,
  });
  final dynamic error;
}

class LoadChatMessagesCubit extends Cubit<LoadChatMessagesState> {
  LoadChatMessagesCubit() : super(LoadChatMessagesInitial());
  final ChatRepository _chatRepostiory = ChatRepository();

  Future<void> load({
    required int userId,
    required int propertyId,
  }) async {
    try {
      // Only emit LoadChatMessagesInProgress
      //if we're not already in a success state
      if (state is! LoadChatMessagesSuccess) {
        emit(LoadChatMessagesInProgress());
      } else {
        // Instead of full loading state,
        //just update isLoadingMore in success state
        final currentState = state as LoadChatMessagesSuccess;
        emit(currentState.copyWith(isLoadingMore: true));
      }

      final result = await _chatRepostiory.getMessages(
        page: 1,
        userId: userId,
        propertyId: propertyId,
      );
      final extraData = result.extraData?.data as Map<String, dynamic>?;
      if (result.modelList.isEmpty && result.total == 0) {
        emit(
          LoadChatMessagesSuccess(
            messages: [],
            isBlockedByMe: extraData?['is_blocked_by_me'] as bool? ?? false,
            isBlockedByUser: extraData?['is_blocked_by_user'] as bool? ?? false,
            currentPage: 1,
            propertyId: propertyId,
            isLoadingMore: false,
            totalPage: 0,
            userId: userId,
          ),
        );
        return;
      }

      emit(
        LoadChatMessagesSuccess(
          messages: result.modelList,
          isBlockedByMe: extraData?['is_blocked_by_me'] as bool? ?? false,
          isBlockedByUser: extraData?['is_blocked_by_user'] as bool? ?? false,
          currentPage: 1,
          propertyId: propertyId,
          isLoadingMore: false,
          totalPage: result.total,
          userId: userId,
        ),
      );
    } on ApiException catch (e) {
      // If we were previously in success state, keep the old data
      if (state is LoadChatMessagesSuccess) {
        final currentState = state as LoadChatMessagesSuccess;
        emit(currentState.copyWith(isLoadingMore: false));
      } else {
        emit(LoadChatMessagesFailed(error: e.toString()));
      }
    }
  }

  Future<void> loadMore() async {
    try {
      if (state is LoadChatMessagesSuccess) {
        if ((state as LoadChatMessagesSuccess).isLoadingMore) {
          return;
        }
        emit((state as LoadChatMessagesSuccess).copyWith(isLoadingMore: true));

        final result = await _chatRepostiory.getMessages(
          page: (state as LoadChatMessagesSuccess).currentPage + 1,
          userId: (state as LoadChatMessagesSuccess).userId,
          propertyId: (state as LoadChatMessagesSuccess).propertyId,
        );

        final messagesSuccessState = state as LoadChatMessagesSuccess;

        messagesSuccessState.messages.addAll(result.modelList);

        emit(
          LoadChatMessagesSuccess(
            messages: messagesSuccessState.messages,
            isBlockedByMe: messagesSuccessState.isBlockedByMe,
            isBlockedByUser: messagesSuccessState.isBlockedByUser,
            currentPage: (state as LoadChatMessagesSuccess).currentPage + 1,
            propertyId: (state as LoadChatMessagesSuccess).propertyId,
            isLoadingMore: false,
            totalPage: result.total,
            userId: (state as LoadChatMessagesSuccess).userId,
          ),
        );
      }
    } on ApiException {
      emit((state as LoadChatMessagesSuccess).copyWith(isLoadingMore: false));
    }
  }

  bool hasMoreChat() {
    if (state is LoadChatMessagesSuccess) {
      return (state as LoadChatMessagesSuccess).currentPage <
          (state as LoadChatMessagesSuccess).totalPage;
    }
    return false;
  }

  void clear() {
    emit(LoadChatMessagesInitial());
  }
}
