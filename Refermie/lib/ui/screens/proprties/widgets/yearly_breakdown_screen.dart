import 'package:ebroker/data/model/mortgage_calculator_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/price_format.dart';
import 'package:flutter/material.dart';

class YearlyBreakdownScreen extends StatefulWidget {
  const YearlyBreakdownScreen({
    required this.mortgageCalculatorModel,
    super.key,
  });
  final MortgageCalculatorModel mortgageCalculatorModel;

  @override
  State<YearlyBreakdownScreen> createState() => _YearlyBreakdownScreenState();
}

class _YearlyBreakdownScreenState extends State<YearlyBreakdownScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.mortgageCalculatorModel.yearlyTotals.isEmpty
        ? Center(
            child: NoDataFound(
              title: 'noYearlyBreakdownFound'.translate(context),
              description: 'noYearlyBreakdownFoundDescription'.translate(
                context,
              ),
              onTapRetry: () {},
              showRetryButton: false,
            ),
          )
        : Scaffold(
            backgroundColor: context.color.secondaryColor,
            appBar: CustomAppBar(
              title: 'yearlyBreakdown'.translate(context),
            ),
            body: SingleChildScrollView(
              physics: Constant.scrollPhysics,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: context.color.tertiaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Expanded(
                          child: _buildSummaryRow(
                            'principalAmount'.translate(context),
                            (widget
                                        .mortgageCalculatorModel
                                        .mainTotal
                                        ?.principalAmount ??
                                    '0')
                                .priceFormat(context: context),
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryRow(
                            'monthlyEMI'.translate(context),
                            (widget
                                        .mortgageCalculatorModel
                                        .mainTotal
                                        ?.monthlyEmi ??
                                    '0')
                                .priceFormat(context: context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ...List.generate(
                    widget.mortgageCalculatorModel.yearlyTotals.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 8),
                        child: _buildYearContent(
                          yearData: widget
                              .mortgageCalculatorModel
                              .yearlyTotals[index],
                          initiallyExpanded: index == 0,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildYearContent({
    required YearlyTotals yearData,
    required bool initiallyExpanded,
  }) {
    return ExpansionTile(
      childrenPadding: EdgeInsets.zero,
      expandedAlignment: Alignment.centerLeft,
      iconColor: context.color.tertiaryColor,
      collapsedIconColor: context.color.inverseSurface,
      title: CustomText(
        yearData.year ?? '',
        fontWeight: .bold,
        fontSize: context.font.lg,
      ),
      textColor: context.color.tertiaryColor,
      collapsedTextColor: context.color.textColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: context.color.borderColor,
        ),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: context.color.borderColor,
        ),
      ),
      collapsedBackgroundColor: context.color.secondaryColor,
      backgroundColor: context.color.secondaryColor,
      initiallyExpanded: initiallyExpanded,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: _buildSummaryRow(
                'principalAmount'.translate(context),
                (yearData.principalAmount ?? '').priceFormat(context: context),
              ),
            ),
            Expanded(
              child: _buildSummaryRow(
                'outstandingAmount'.translate(context),
                (yearData.remainingBalance ?? '0').priceFormat(
                  context: context,
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
          ],
        ),
        _buildPaymentScheduleTable(monthData: yearData.monthlyTotals ?? []),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _buildPaymentScheduleTable({required List<MonthlyTotals> monthData}) {
    const cellPadding = 8.0;
    final isTablet = ResponsiveHelper.isTablet(context);

    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth:
              MediaQuery.of(context).size.width -
              32, // Account for parent padding
        ),
        child: DataTable(
          dividerThickness: 0,
          columnSpacing: isTablet ? 8 : 4,
          headingRowColor: WidgetStatePropertyAll(context.color.tertiaryColor),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 56,
          columns: [
            DataColumn(
              label: Container(
                width: isTablet ? 80 : 60,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  'month'.translate(context),
                  fontWeight: .bold,
                  fontSize: context.font.xs,
                  color: context.color.primaryColor,
                  textAlign: .center,
                ),
              ),
            ),
            DataColumn(
              label: Container(
                width: isTablet ? 120 : 90,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  'principal'.translate(context),
                  fontWeight: .bold,
                  fontSize: context.font.xs,
                  color: context.color.primaryColor,
                  textAlign: .center,
                ),
              ),
            ),
            DataColumn(
              label: Container(
                width: isTablet ? 120 : 90,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  'interest'.translate(context),
                  fontWeight: .bold,
                  fontSize: context.font.xs,
                  color: context.color.primaryColor,
                  textAlign: .center,
                ),
              ),
            ),
            DataColumn(
              label: Container(
                width: isTablet ? 140 : 110,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: cellPadding),
                child: CustomText(
                  'outstanding'.translate(context),
                  fontWeight: .bold,
                  fontSize: context.font.xs,
                  color: context.color.primaryColor,
                  textAlign: .center,
                ),
              ),
            ),
          ],
          rows: List.generate(
            monthData.length,
            (index) => DataRow(
              color: index.isOdd
                  ? WidgetStatePropertyAll(
                      context.color.tertiaryColor.withValues(alpha: 0.1),
                    )
                  : WidgetStatePropertyAll(context.color.secondaryColor),
              cells: [
                DataCell(
                  Container(
                    width: isTablet ? 80 : 60,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: cellPadding,
                    ),
                    child: CustomText(
                      '${monthData[index].month?.substring(0, 3)}'
                          .toLowerCase()
                          .translate(context),
                      textAlign: .center,
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: .w600,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: isTablet ? 120 : 90,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: cellPadding,
                    ),
                    child: CustomText(
                      (monthData[index].principalAmount ?? '0').priceFormat(
                        context: context,
                      ),
                      textAlign: .center,
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: .w600,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: isTablet ? 120 : 90,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: cellPadding,
                    ),
                    child: CustomText(
                      (monthData[index].payableInterest ?? '0').priceFormat(
                        context: context,
                      ),
                      textAlign: .center,
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: .w600,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: isTablet ? 140 : 110,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: cellPadding,
                    ),
                    child: CustomText(
                      (monthData[index].remainingBalance ?? '0').priceFormat(
                        context: context,
                      ),
                      textAlign: .center,
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: .w600,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          CustomText(
            label,
            fontSize: context.font.md,
          ),
          CustomText(
            value,

            fontSize: context.font.xl,
            fontWeight: .bold,
          ),
        ],
      ),
    );
  }
}
