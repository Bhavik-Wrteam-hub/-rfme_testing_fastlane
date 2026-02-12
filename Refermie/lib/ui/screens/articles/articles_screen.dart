import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/articles/article_card.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' show Html;

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key, this.isFromHome = false});

  final bool isFromHome;

  static Route<dynamic> route(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>? ?? {};
    final isFromHome = arguments['isFromHome'] as bool? ?? false;
    return CupertinoPageRoute(
      builder: (context) {
        return ArticlesScreen(isFromHome: isFromHome);
      },
    );
  }

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    unawaited(context.read<FetchArticlesCubit>().fetchArticles());
    _pageScrollController.addListener(pageScrollListen);
    super.initState();
  }

  Future<void> pageScrollListen() async {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchArticlesCubit>().hasMoreData()) {
        await context.read<FetchArticlesCubit>().fetchArticlesMore();
      }
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'articles'.translate(context),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await context.read<FetchArticlesCubit>().fetchArticles();
        },
        child: BlocBuilder<FetchArticlesCubit, FetchArticlesState>(
          builder: (context, state) {
            if (state is FetchArticlesInProgress) {
              return buildArticlesShimmer();
            }
            if (state is FetchArticlesFailure) {
              if (state.errorMessage is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () {
                    unawaited(
                      context.read<FetchArticlesCubit>().fetchArticles(),
                    );
                  },
                );
              }

              return SomethingWentWrong(
                errorMessage: state.errorMessage.toString(),
              );
            }
            if (state is FetchArticlesSuccess) {
              if (state.articlemodel.isEmpty) {
                return NoDataFound(
                  title: 'noArticlesFound'.translate(context),
                  description: 'noArticlesFoundDescription'.translate(context),
                  onTapRetry: () async {
                    await context.read<FetchArticlesCubit>().fetchArticles();
                  },
                );
              }
              return Column(
                mainAxisSize: .min,
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 8,
                      ),
                      controller: _pageScrollController,
                      shrinkWrap: true,
                      physics: Constant.scrollPhysics,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.articlemodel.length,
                      itemBuilder: (context, index) {
                        final article = state.articlemodel[index];

                        return buildArticleCard(
                          context,
                          article: article,
                          isFromHome: widget.isFromHome,
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore) const CircularProgressIndicator(),
                  if (state.loadingMoreError)
                    CustomText('somethingWentWrng'.translate(context)),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget buildArticleCard(
    BuildContext context, {
    required ArticleModel article,
    required bool isFromHome,
  }) {
    return ArticleCard(article: article, isFromHome: isFromHome);
  }

  Widget buildArticlesShimmer() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: 10,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          height: 279.rh(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: context.color.secondaryColor,
            border: Border.all(
              color: context.color.borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              CustomShimmer(
                width: double.infinity,
                height: 160.rh(context),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8),
                child: CustomShimmer(
                  width: 100.rw(context),
                  height: 10.rh(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: CustomShimmer(
                  width: 160.rw(context),
                  height: 10.rh(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: CustomShimmer(
                  width: 150.rw(context),
                  height: 10.rh(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: CustomShimmer(
                  width: 100.rw(context),
                  height: 10.rh(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Container article(FetchArticlesSuccess state, int index) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: <Widget>[
              CustomText(
                state.articlemodel[index].title!,
                color: Colors.black,
              ),
              const Divider(),
              if (state.articlemodel[index].image != '') ...[
                Image.network(state.articlemodel[index].image!),
              ],
              const Divider(),
              Html(data: state.articlemodel[index].description),
            ],
          ),
        ),
      ),
    );
  }
}
