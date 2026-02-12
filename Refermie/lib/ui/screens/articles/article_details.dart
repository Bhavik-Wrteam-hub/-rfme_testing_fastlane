import 'package:ebroker/data/cubits/fetch_single_article_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class ArticleDetails extends StatefulWidget {
  const ArticleDetails({super.key});

  static Route<dynamic> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) {
        return const ArticleDetails();
      },
    );
  }

  @override
  State<ArticleDetails> createState() => _ArticleDetailsState();
}

class _ArticleDetailsState extends State<ArticleDetails> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await context.read<FetchArticlesCubit>().fetchArticles();
        Navigator.pop(context);
      },
      child: BlocBuilder<FetchSingleArticleCubit, FetchSingleArticleState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.color.primaryColor,
            appBar: CustomAppBar(
              onTapBackButton: () async {
                await context.read<FetchArticlesCubit>().fetchArticles();
              },
              actions: [
                if (state is FetchSingleArticleSuccess)
                  GestureDetector(
                    onTap: () async {
                      await HelperUtils.shareArticle(
                        context,
                        state.articlemodel.slugId ?? '',
                      );
                    },
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(end: 16),
                      alignment: Alignment.center,
                      child: CustomImage(
                        imageUrl: AppIcons.shareIcon,
                        height: 24.rh(context),
                        color: context.color.textColorDark,
                      ),
                    ),
                  ),
              ],
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(FetchSingleArticleState state) {
    return Builder(
      builder: (context) {
        if (state is FetchSingleArticleFailure) {
          return SomethingWentWrong(
            errorMessage: state.errorMessage.toString(),
          );
        }
        if (state is FetchSingleArticleInProgress) {
          return Center(
            child: UiUtils.progress(),
          );
        }
        if (state is FetchSingleArticleSuccess) {
          return SingleChildScrollView(
            physics: Constant.scrollPhysics,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: context.screenWidth,
                      height: 211.rh(context),
                      child: CustomImage(
                        imageUrl: state.articlemodel.image!,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.rh(context)),
                  Row(
                    children: [
                      Container(
                        height: 16.rh(context),
                        width: 16.rw(context),
                        alignment: Alignment.center,
                        child: CustomImage(
                          imageUrl: AppIcons.calendar,
                          color: context.color.textLightColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      CustomText(
                        state.articlemodel.date == null
                            ? ''
                            : state.articlemodel.date.toString().formatDate(),
                        color: context.color.textLightColor,
                        fontWeight: .w400,
                        fontSize: context.font.xxs,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16.rh(context),
                        width: 16.rw(context),
                        alignment: Alignment.center,
                        child: CustomImage(
                          imageUrl: AppIcons.eye,
                          color: context.color.textLightColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      CustomText(
                        state.articlemodel.viewCount ?? '',
                        color: context.color.textLightColor,
                        fontWeight: .w400,
                        fontSize: context.font.xxs,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.rh(context)),
                  CustomText(
                    (state.articlemodel.translatedTitle ??
                            state.articlemodel.title ??
                            '')
                        .firstUpperCase(),
                    fontWeight: .w500,
                    fontSize: context.font.md,
                    color: context.color.textColorDark,
                  ),
                  SizedBox(height: 8.rh(context)),
                  CustomText(
                    stripHtmlTags(
                      state.articlemodel.translatedDescription ??
                          state.articlemodel.description ??
                          '',
                    ).trim(),
                    fontSize: context.font.xs,
                    maxLines: 999999999,
                    fontWeight: .w400,
                    color: context.color.textLightColor,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String stripHtmlTags(String htmlString) {
    final exp = RegExp('<[^>]*>', multiLine: true);
    final strippedString = htmlString.replaceAll(exp, '');
    return strippedString;
  }
}
