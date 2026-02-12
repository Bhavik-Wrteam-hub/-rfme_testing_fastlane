import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class GenerateWithAiButton extends StatelessWidget {
  const GenerateWithAiButton({
    required this.onTap,
    required this.isLoading,
    super.key,
  });
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!AppSettings.isAIEnabled) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.color.tertiaryColor.withValues(alpha: 0.08),
          border: Border.all(
            color: context.color.tertiaryColor.withValues(alpha: 0.35),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            CustomImage(
              imageUrl: AppIcons.sparkles,
              width: 16.rh(context),
              height: 16.rh(context),
              color: context.color.tertiaryColor,
            ),
            const SizedBox(width: 6),
            CustomText(
              isLoading
                  ? 'generating'.translate(context)
                  : 'generateWithAI'.translate(context),
              fontSize: context.font.xs,
              color: context.color.tertiaryColor,
              fontWeight: .w600,
            ),
          ],
        ),
      ),
    );
  }
}
