import 'dart:async';

import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/fetch_single_article_cubit.dart';
import 'package:ebroker/data/model/article_model.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    required this.article,
    super.key,
    this.isFromHome = false,
  });
  final bool isFromHome;
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: isFromHome ? 280.rw(context) : double.infinity,
      height: isFromHome ? 240.rh(context) : 279.rh(context),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          unawaited(
            context.read<FetchSingleArticleCubit>().fetchArticlesById(
              article.id.toString(),
            ),
          );
          await Navigator.pushNamed(
            context,
            Routes.articleDetailsScreenRoute,
          );
        },
        child: Column(
          crossAxisAlignment: .start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomImage(
                imageUrl: article.image ?? '',
                width: double.infinity,
                fit: .fill,
                height: 151.rh(context),
              ),
            ),
            const SizedBox(height: 8),
            CustomText(
              (article.translatedTitle ?? article.title ?? '').firstUpperCase(),
              maxLines: isFromHome ? 1 : 2,
              color: context.color.textColorDark,
              fontWeight: .w500,
              fontSize: context.font.sm,
            ),
            CustomText(
              stripHtmlTags(
                article.translatedDescription ?? article.description ?? '',
              ).trim(),
              maxLines: isFromHome ? 1 : 2,
              color: context.color.textLightColor,
              fontWeight: .w400,
              fontSize: context.font.xs,
            ),
            const Spacer(),
            UiUtils.getDivider(context),
            const SizedBox(height: 8),
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
                  article.date == null
                      ? article.postedOn == null
                            ? ''
                            : article.postedOn.toString()
                      : article.date.toString().formatDate(),
                  color: context.color.textLightColor,
                  fontWeight: .w400,
                  fontSize: context.font.xxs,
                  maxLines: 1,
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
                  article.viewCount ?? '',
                  color: context.color.textLightColor,
                  fontWeight: .w400,
                  maxLines: 1,
                  fontSize: context.font.xxs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String stripHtmlTags(String htmlString) {
  final exp = RegExp('<[^>]*>', multiLine: true);
  final strippedString = htmlString.replaceAll(exp, '');
  return strippedString;
}
