import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/model/home_page_data_model.dart';
import 'package:ebroker/data/model/home_section_data_model.dart';
import 'package:ebroker/data/model/other_sections_model.dart';
import 'package:ebroker/data/model/project_sections_model.dart';
import 'package:ebroker/data/model/property_sections_model.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchHomePageDataState {}

class FetchHomePageDataInitial extends FetchHomePageDataState {}

class FetchHomePageDataLoading extends FetchHomePageDataState {}

class FetchHomePageDataSuccess extends FetchHomePageDataState {
  FetchHomePageDataSuccess({
    required this.homePageDataModel,
    this.refreshing = false,
  });

  final HomePageDataModel homePageDataModel;
  final bool refreshing;

  FetchHomePageDataSuccess copyWith({
    HomePageDataModel? homePageDataModel,
    bool? refreshing,
  }) {
    return FetchHomePageDataSuccess(
      homePageDataModel: homePageDataModel ?? this.homePageDataModel,
      refreshing: refreshing ?? this.refreshing,
    );
  }
}

class FetchHomePageDataFailure extends FetchHomePageDataState {
  FetchHomePageDataFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchHomePageDataCubit extends Cubit<FetchHomePageDataState> {
  FetchHomePageDataCubit()
    : super(
        FetchHomePageDataSuccess(
          homePageDataModel: HomePageDataModel.empty(),
        ),
      );

  /// Inject section order/configuration from `/homepage/sections-data`.
  void setSectionsOrder(HomeSectionDataModel sectionsData) {
    if (state is! FetchHomePageDataSuccess) return;
    final success = state as FetchHomePageDataSuccess;
    final merged = success.homePageDataModel.copyWith(
      originalSections: sectionsData.sections,
    );
    emit(success.copyWith(homePageDataModel: merged));
  }

  /// Inject property sections from `/homepage/property-sections`.
  void setPropertySections(PropertySectionsModel model) {
    if (state is! FetchHomePageDataSuccess) return;
    final success = state as FetchHomePageDataSuccess;
    final merged = success.homePageDataModel.copyWith(
      nearByProperties: model.nearbyProperties,
      featuredSection: model.featuredProperties,
      mostViewedProperties: model.mostViewedProperties,
      mostLikedProperties: model.mostLikedProperties,
      premiumProperties: model.premiumProperties,
      // This flag is used to decide whether we should keep passing location params.
      homePageLocationDataAvailable: model.locationBasedData,
    );
    emit(success.copyWith(homePageDataModel: merged));
  }

  /// Inject project sections from `/homepage/project-sections`.
  void setProjectSections(ProjectSectionsModel model) {
    if (state is! FetchHomePageDataSuccess) return;
    final success = state as FetchHomePageDataSuccess;
    final merged = success.homePageDataModel.copyWith(
      projectSection: model.projects,
      featuredProjectSection: model.featuredProjects,
    );
    emit(success.copyWith(homePageDataModel: merged));
  }

  /// Inject other sections from `/homepage/other-sections`.
  void setOtherSections(OtherSectionsModel model) {
    if (state is! FetchHomePageDataSuccess) return;
    final success = state as FetchHomePageDataSuccess;
    final merged = success.homePageDataModel.copyWith(
      categoriesSection: model.categories,
      agentsList: model.agents,
      articleSection: model.articles,
      personalizedProperties: model.userRecommendations,
      sliderSection: model.slider,
    );
    emit(success.copyWith(homePageDataModel: merged));
  }

  /// Merge properties-by-cities into existing success state
  void setCities(List<City> cities) {
    if (state is! FetchHomePageDataSuccess) return;
    final success = state as FetchHomePageDataSuccess;
    final merged = success.homePageDataModel.copyWith(
      propertiesByCities: cities,
    );
    emit(success.copyWith(homePageDataModel: merged));
  }

  bool isHomePageDataEmpty() {
    if (state is FetchHomePageDataSuccess) {
      return (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .featuredSection!
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .mostLikedProperties!
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .mostViewedProperties!
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .projectSection!
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .sliderSection!
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .categoriesSection!
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .articleSection!
              .isEmpty ||
          (state as FetchHomePageDataSuccess)
              .homePageDataModel
              .agentsList!
              .isEmpty;
    }
    return true;
  }
}
