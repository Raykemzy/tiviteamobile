import 'package:flutter/material.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';

class ArtisanSummarySection extends StatelessWidget {
  const ArtisanSummarySection({super.key, required this.artisan});

  final ArtisanResponseModel artisan;

  @override
  Widget build(BuildContext context) {
    final summary = artisan.summaryText;
    if (summary == null || summary.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: context.theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          summary,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF737380),
          ),
        ),
      ],
    );
  }
}
