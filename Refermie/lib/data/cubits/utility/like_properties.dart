import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

class LikedPropertiesState {
  const LikedPropertiesState({required this.likedProperties});

  factory LikedPropertiesState.fromMap(Map<String, dynamic> map) {
    return LikedPropertiesState(
      likedProperties: Set<int>.from(map['liked'] as List),
    );
  }
  factory LikedPropertiesState.fromJson(String source) =>
      LikedPropertiesState.fromMap(json.decode(source) as Map<String, dynamic>);
  final Set<int> likedProperties;

  LikedPropertiesState copyWith({
    Set<int>? likedProperties,
  }) {
    return LikedPropertiesState(
      likedProperties: likedProperties ?? this.likedProperties,
    );
  }

  Map<String, dynamic> toMap() => {'liked': likedProperties.toList()};
  String toJson() => json.encode(toMap());
  @override
  String toString() =>
      'LikedPropertiesState(likedProperties: $likedProperties)';
}

class LikedPropertiesCubit extends Cubit<LikedPropertiesState> {
  LikedPropertiesCubit()
      : super(const LikedPropertiesState(likedProperties: {}));

  /// Initializes the cubit with a set of favorite IDs fetched from the server.
  /// This should be called once after login.
  void setFavorites(List<int> propertyIds) {
    emit(LikedPropertiesState(likedProperties: Set.from(propertyIds)));
  }

  /// Toggles the like status for a given property ID.
  /// This creates a new state object, ensuring immutability.
  void toggleLike(int id) {
    final newSet = Set<int>.from(state.likedProperties);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    setFavorites(newSet.toList());
    emit(LikedPropertiesState(likedProperties: newSet));
  }

  void clear() {
    emit(const LikedPropertiesState(likedProperties: {}));
  }
}
