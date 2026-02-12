import 'package:ebroker/data/cubits/fetch_faqs_cubit.dart';
import 'package:ebroker/data/model/faqs_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:ebroker/ui/screens/widgets/read_more_text.dart';
import 'package:flutter/material.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({
    super.key,
  });

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const FaqsScreen(),
    );
  }

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  @override
  void initState() {
    unawaited(
      context.read<FetchFaqsCubit>().fetchFaqs(
        forceRefresh: false,
      ),
    );
    addPageScrollListener();
    super.initState();
  }

  void addPageScrollListener() {
    faqsListScreenController.addListener(pageScrollListener);
  }

  Future<void> pageScrollListener() async {
    ///This will load data on page end
    if (faqsListScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<FetchFaqsCubit>().hasMoreData()) {
          await context.read<FetchFaqsCubit>().fetchMore();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: 'faqScreen'.translate(context),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await context.read<FetchFaqsCubit>().fetchFaqs(
            forceRefresh: true,
          );
        },
        child: SingleChildScrollView(
          physics: Constant.scrollPhysics,
          controller: faqsListScreenController,
          child: Column(
            children: <Widget>[
              BlocBuilder<FetchFaqsCubit, FetchFaqsState>(
                builder: (context, state) {
                  if (state is FetchFaqsFailure) {
                    return SomethingWentWrong(
                      errorMessage: state.errorMessage,
                    );
                  }
                  if (state is FetchFaqsInProgress) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        left: 18,
                        right: 18,
                        top: 8,
                        bottom: 25,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        return const Column(
                          children: [
                            CustomShimmer(
                              height: 48,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        );
                      },
                    );
                  }
                  if (state is FetchFaqsSuccess && state.faqs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: NoDataFound(
                        title: 'noFaqsFound'.translate(context),
                        description: 'noFaqsFoundDescription'.translate(
                          context,
                        ),
                        onTapRetry: () async {
                          await context.read<FetchFaqsCubit>().fetchFaqs(
                            forceRefresh: true,
                          );
                        },
                      ),
                    );
                  }
                  if (state is FetchFaqsSuccess && state.faqs.isNotEmpty) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        left: 18,
                        right: 18,
                        top: 8,
                        bottom: 25,
                      ),
                      itemCount: state.faqs.length,
                      itemBuilder: (context, index) {
                        final faq = state.faqs[index];
                        return Column(
                          children: [
                            FaqsCard(faq: faq),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return Container();
                },
              ),
              if (context.watch<FetchFaqsCubit>().isLoadingMore()) ...[
                Center(child: UiUtils.progress()),
              ],
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaqsCard extends StatelessWidget {
  const FaqsCard({required this.faq, super.key});
  final FaqsModel faq;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: context.color.borderColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      collapsedShape: RoundedRectangleBorder(
        side: BorderSide(
          color: context.color.borderColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      collapsedBackgroundColor: context.color.secondaryColor,
      backgroundColor: context.color.secondaryColor,
      // collapsedIconColor: context.color.tertiaryColor,
      iconColor: context.color.tertiaryColor,
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      title: CustomText(
        faq.translatedQuestion ?? faq.question ?? '',
        maxLines: 2,
        fontWeight: .w600,
        fontSize: context.font.lg,
        color: context.color.textColorDark,
      ),
      children: [
        ReadMoreText(
          text: faq.translatedAnswer ?? faq.answer ?? '',
          style: TextStyle(
            color: context.color.inverseSurface,
            fontSize: context.font.sm,
          ),
          readMoreButtonStyle: TextStyle(
            color: context.color.tertiaryColor,
            fontSize: context.font.sm,
          ),
        ),
      ],
    );
  }
}
