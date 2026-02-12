import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

///In this file https://dart.dev/language/generics generic types are used For more info you can see this

///This [PropertySuccessStateWireframe] this will force class to have properties list

abstract class PropertySuccessStateWireframe {
  abstract List<PropertyModel> properties;
  abstract bool isLoadingMore;
}

///this will force class to have error field
abstract class PropertyErrorStateWireframe {
  dynamic error;
}

///This implementation is for cubit this will force property cubit to implement this methods.
abstract class PropertyCubitWireframe {
  void fetch();

  bool hasMoreData();

  void fetchMore();
}

class ViewAllScreen<T extends StateStreamable<C>, C> extends StatefulWidget {
  const ViewAllScreen({
    required this.title,
    required this.map,
    super.key,
  }) : assert(
         T is! PropertyErrorStateWireframe,
         'Please Extend PropertyErrorStateWireframe in cubit',
       );

  final String title;
  final StateMap<
    dynamic,
    dynamic,
    PropertySuccessStateWireframe,
    PropertyErrorStateWireframe
  >
  map;

  Future<void> open(BuildContext context) async {
    await Navigator.push(
      context,
      CupertinoPageRoute<dynamic>(
        builder: (context) {
          return ViewAllScreen<T, C>(title: title, map: map);
        },
      ),
    );
  }

  @override
  ViewAllScreenState<T, C> createState() => ViewAllScreenState<T, C>();
}

class ViewAllScreenState<T extends StateStreamable<C>, C>
    extends State<ViewAllScreen<dynamic, dynamic>> {
  final ScrollController _pageScrollListener = ScrollController();

  @override
  void initState() {
    super.initState();

    // Ensure we call fetch after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<T>() is PropertyCubitWireframe) {
        (context.read<T>() as PropertyCubitWireframe).fetch();
      }
    });

    _pageScrollListener.addListener(onPageEnd);
  }

  @override
  void dispose() {
    _pageScrollListener.dispose();
    super.dispose();
  }

  bool isSubtype<S, T>() => <S>[] is List<T>;

  void onPageEnd() {
    ///This is extension which will check if we reached end or not
    if (_pageScrollListener.isEndReached()) {
      if (isSubtype<T, PropertyCubitWireframe>()) {
        if ((context.read<T>() as PropertyCubitWireframe).hasMoreData()) {
          (context.read<T>() as PropertyCubitWireframe).fetchMore();
        }
      }
    }
  }

  dynamic read<X>() {
    return context.read<X>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, C>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: CustomAppBar(
            title: widget.title,
          ),
          bottomNavigationBar:
              state is PropertySuccessStateWireframe && state.isLoadingMore
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.rh(context)),
                  child: UiUtils.progress(
                    height: 30.rh(context),
                    width: 30.rw(context),
                  ),
                )
              : null,
          body: widget.map._buildState(state, _pageScrollListener, context),
        );
      },
    );
  }
}

///From generic type we are getting state so we can return ui according to that state
class StateMap<
  INITIAL,
  PROGRESS,
  SUCCESS extends PropertySuccessStateWireframe,
  FAIL extends PropertyErrorStateWireframe
> {
  Widget _buildState(
    dynamic state,
    ScrollController controller,
    BuildContext context,
  ) {
    if (state is INITIAL) {
      return Container();
    }
    if (state is PROGRESS) {
      return UiUtils.buildHorizontalShimmer(context);
    }
    if (state is FAIL) {
      return Center(
        child: SomethingWentWrong(
          errorMessage: state.error.toString(),
        ),
      );
    }
    if (state is SUCCESS && state.properties.isEmpty) {
      return NoDataFound(
        title: 'noPropertyFound'.translate(context),
        description: 'noPropertyFoundDescription'.translate(context),
        onTapRetry: () {},
        showRetryButton: false,
      );
    }
    if (state is SUCCESS && state.properties.isNotEmpty) {
      return Column(
        children: [
          Expanded(
            child:
                ResponsiveHelper.isLargeTablet(context) ||
                    ResponsiveHelper.isTablet(context)
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: 130.rh(context),
                    ),
                    physics: Constant.scrollPhysics,
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final model = state.properties[index];
                      return PropertyHorizontalCard(property: model);
                    },
                    itemCount: state.properties.length,
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 8.rh(context)),
                    physics: Constant.scrollPhysics,
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final model = state.properties[index];
                      return PropertyHorizontalCard(property: model);
                    },
                    itemCount: state.properties.length,
                  ),
          ),
        ],
      );
    }

    return Container();
  }
}
