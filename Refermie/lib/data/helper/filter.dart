import 'package:ebroker/utils/constant.dart';
import 'package:flutter/material.dart';

/// Base filter class using sealed class for exhaustive pattern matching

// Consider adding these extensions for even cleaner code:

extension FilterApplyExtensions on FilterApply {
  // Check if specific filter types are active
  bool get hasPropertyTypeFilter => !get<PropertyTypeFilter>().isEmpty;
  bool get hasBudgetFilter => !get<MinMaxBudget>().isEmpty;
  bool get hasCategoryFilter => !get<CategoryFilter>().isEmpty;
  bool get hasLocationFilter => !get<LocationFilter>().isEmpty;
  bool get hasFacilitiesFilter => !get<FacilitiesFilter>().isEmpty;
  bool get hasPostedSinceFilter => !get<PostedSince>().isEmpty;
  bool get hasNearbyPlacesFilter => !get<NearbyPlacesFilter>().isEmpty;

  // Get a summary of active filters for display
  String getFilterSummary(BuildContext context) {
    final summary = <String>[];

    if (hasPropertyTypeFilter) {
      final type = get<PropertyTypeFilter>().type;
      summary.add(type == Constant.valRent ? 'Rent' : 'Sale');
    }

    if (hasBudgetFilter) {
      final budget = get<MinMaxBudget>();
      if (budget.min != null && budget.max != null) {
        summary.add('${Constant.currencySymbol}${budget.min}-${budget.max}');
      } else if (budget.min != null) {
        summary.add('Min ${Constant.currencySymbol}${budget.min}');
      } else if (budget.max != null) {
        summary.add('Max ${Constant.currencySymbol}${budget.max}');
      }
    }

    if (hasLocationFilter) {
      final location = get<LocationFilter>();
      summary.add(location.city ?? 'Custom Location');
    }

    return summary.isEmpty ? 'No filters' : summary.join(' • ');
  }
}

// Consider creating a FilterState class for better state management:
class FilterState extends ChangeNotifier {
  FilterApply _filter = FilterApply();

  FilterApply get filter => _filter;

  void updateFilter(Filter newFilter) {
    _filter.addOrUpdate(newFilter);
    notifyListeners();
  }

  void clearFilters() {
    _filter.clear();
    notifyListeners();
  }

  void applyFilter(FilterApply newFilter) {
    _filter = newFilter.copy();
    notifyListeners();
  }
}

sealed class Filter {
  const Filter();

  Map<String, dynamic> toMap();

  /// Registry of empty filter constructors
  static final Map<Type, Filter Function()> _emptyRegistry = {
    PropertyTypeFilter: PropertyTypeFilter.empty,
    PostedSince: PostedSince.empty,
    MinMaxBudget: MinMaxBudget.empty,
    CategoryFilter: CategoryFilter.empty,
    LocationFilter: LocationFilter.empty,
    FacilitiesFilter: FacilitiesFilter.empty,
    NearbyPlacesFilter: NearbyPlacesFilter.empty,
  };

  /// Factory method to create empty filter based on type
  static T empty<T extends Filter>() {
    final constructor = _emptyRegistry[T];
    if (constructor == null) {
      throw ArgumentError('Unknown filter type: $T');
    }
    return constructor() as T;
  }
}

class PropertyTypeFilter extends Filter {
  const PropertyTypeFilter(this.type);

  final String type;

  static PropertyTypeFilter empty() => const PropertyTypeFilter('');

  bool get isEmpty => type.isEmpty;

  @override
  Map<String, dynamic> toMap() => {'property_type': type};
}

class MinMaxBudget extends Filter {
  const MinMaxBudget({
    this.min,
    this.max,
  });

  final String? min;
  final String? max;

  static MinMaxBudget empty() => const MinMaxBudget();

  bool get isEmpty => (min?.isEmpty ?? true) && (max?.isEmpty ?? true);

  @override
  Map<String, dynamic> toMap() {
    final priceMap = <String, dynamic>{};
    if (min?.isNotEmpty ?? false) priceMap['min_price'] = min;
    if (max?.isNotEmpty ?? false) priceMap['max_price'] = max;

    if (priceMap.isEmpty) return {};

    return {'price': priceMap};
  }
}

class FacilitiesFilter extends Filter {
  const FacilitiesFilter(this.facilities);

  final List<int> facilities;

  static FacilitiesFilter empty() => const FacilitiesFilter([]);

  bool get isEmpty => facilities.isEmpty;

  @override
  Map<String, dynamic> toMap() {
    final parameters = <Map<String, dynamic>>[];
    // Values will be added in future
    for (final facility in facilities) {
      parameters.add({
        'id': facility,
        'value': '',
      });
    }
    return facilities.isNotEmpty ? {'parameters': parameters} : {};
  }
}

class CategoryFilter extends Filter {
  const CategoryFilter(this.categoryId);

  final String? categoryId;

  static CategoryFilter empty() => const CategoryFilter(null);

  bool get isEmpty => categoryId == null || categoryId!.isEmpty;

  @override
  Map<String, dynamic> toMap() {
    return categoryId != null ? {'category_id': categoryId} : {};
  }
}

enum PostedSinceDuration {
  anytime(''),
  lastWeek('0'),
  yesterday('1'),
  lastMonth('2'),
  lastThreeMonth('3'),
  lastSixMonth('4');

  const PostedSinceDuration(this.value);
  final String value;
}

class PostedSince extends Filter {
  const PostedSince(this.since);

  final PostedSinceDuration since;

  static PostedSince empty() => const PostedSince(PostedSinceDuration.anytime);

  bool get isEmpty => since == PostedSinceDuration.anytime;

  @override
  Map<String, dynamic> toMap() {
    return since.value.isNotEmpty ? {'posted_since': since.value} : {};
  }
}

class LocationFilter extends Filter {
  const LocationFilter({
    this.placeId,
    this.city,
    this.state,
    this.country,
  });

  final String? placeId;
  final String? city;
  final String? state;
  final String? country;

  static LocationFilter empty() => const LocationFilter();

  bool get isEmpty =>
      (placeId?.isEmpty ?? true) &&
      (city?.isEmpty ?? true) &&
      (state?.isEmpty ?? true) &&
      (country?.isEmpty ?? true);

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (placeId?.isNotEmpty ?? false) map['place_id'] = placeId;
    if (city?.isNotEmpty ?? false) map['city'] = city;
    if (state?.isNotEmpty ?? false) map['state'] = state;
    if (country?.isNotEmpty ?? false) map['country'] = country;
    return {'location': map};
  }
}

class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.value,
  });
  factory NearbyPlace.fromMap(Map<String, dynamic> map) {
    return NearbyPlace(
      id: map['id'] as int,
      value: map['value'] as String,
    );
  }
  final int id;
  final String value;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
    };
  }
}

class NearbyPlacesFilter extends Filter {
  const NearbyPlacesFilter(this.nearbyPlaces);
  final List<NearbyPlace> nearbyPlaces;

  static NearbyPlacesFilter empty() => const NearbyPlacesFilter([]);

  bool get isEmpty => nearbyPlaces.isEmpty;

  @override
  Map<String, dynamic> toMap() {
    if (nearbyPlaces.isEmpty) return {};

    return {
      'nearby_places': nearbyPlaces.map((place) => place.toMap()).toList(),
    };
  }
}

/// Optimized FilterApply with better performance and type safety
class FilterApply {
  // Using a Map for O(1) lookups instead of List for O(n)
  final Map<Type, Filter> _filters = {};

  /// Add or update a filter
  void addOrUpdate(Filter filter) {
    _filters[filter.runtimeType] = filter;
  }

  /// Remove a filter by type
  void remove<T extends Filter>() {
    _filters.remove(T);
  }

  /// Clear all filters
  void clear() {
    _filters.clear();
  }

  /// Check if a filter exists
  bool has<T extends Filter>() => _filters.containsKey(T);

  /// Get a filter by type, returns empty filter if not found
  T get<T extends Filter>() {
    final filter = _filters[T];
    if (filter != null) return filter as T;
    return Filter.empty<T>();
  }

  /// Get all active filters (non-empty)
  List<Filter> get activeFilters {
    return _filters.values.where((filter) {
      return switch (filter) {
        PropertyTypeFilter(:final isEmpty) => !isEmpty,
        MinMaxBudget(:final isEmpty) => !isEmpty,
        FacilitiesFilter(:final isEmpty) => !isEmpty,
        CategoryFilter(:final isEmpty) => !isEmpty,
        PostedSince(:final isEmpty) => !isEmpty,
        LocationFilter(:final isEmpty) => !isEmpty,
        NearbyPlacesFilter(:final isEmpty) => !isEmpty,
      };
    }).toList();
  }

  /// Check if any filters are active
  bool get hasActiveFilters => activeFilters.isNotEmpty;

  /// Get combined filter map for API
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    for (final filter in _filters.values) {
      result.addAll(filter.toMap());
    }
    return result;
  }

  /// Create a copy of the current filters
  FilterApply copy() {
    final newFilter = FilterApply();
    newFilter._filters.addAll(_filters);
    return newFilter;
  }

  /// Check equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterApply) return false;

    if (_filters.length != other._filters.length) return false;

    for (final entry in _filters.entries) {
      if (!other._filters.containsKey(entry.key)) return false;
      if (other._filters[entry.key] != entry.value) return false;
    }

    return true;
  }

  @override
  int get hashCode => _filters.hashCode;
}
