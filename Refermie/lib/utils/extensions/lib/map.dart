extension MapExt on Map<dynamic, dynamic> {
  void removeEmptyKeys() {
    removeWhere(
      (key, value) => value.isEmpty as bool? ?? (value == '') || value == null,
    );
  }

  dynamic get(dynamic key) {
    return this[key];
  }
}

extension ListExt on List<Map<dynamic, dynamic>> {
  Map<dynamic, dynamic> findByKey(dynamic key, {dynamic equals}) {
    return where((element) {
      return element[key] == equals;
    }).first;
  }
}
