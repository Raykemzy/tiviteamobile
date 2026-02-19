import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/features/artisans/model/artisan_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/features/artisans/view/widgets/artisan_detail_header.dart';
import 'package:tivi_tea/features/artisans/view/widgets/artisan_professional_summary_section.dart';
import 'package:tivi_tea/features/artisans/view/widgets/artisan_ratings_row.dart';
import 'package:tivi_tea/features/artisans/view/widgets/artisan_request_quotation_section.dart';
import 'package:tivi_tea/features/artisans/view/widgets/artisan_summary_section.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';

class ArtisanDetailView extends StatelessWidget {
  const ArtisanDetailView({super.key, required this.artisan});

  final ArtisanResponseModel artisan;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbar: const CustomAppBar(
        showBackButton: true,
        showHamburgerMenu: true,
        title: 'Artisan Profile',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtisanDetailHeader(artisan: artisan),
            20.verticalSpace,
            ArtisanRatingsRow(artisan: artisan),
            24.verticalSpace,
            ArtisanSummarySection(artisan: artisan),
            if (artisan.summaryText != null && artisan.summaryText!.isNotEmpty)
              24.verticalSpace,
            ArtisanProfessionalSummarySection(artisan: artisan),
            24.verticalSpace,
            ArtisanRequestQuotationSection(artisanId: artisan.id ?? ''),
          ],
        ),
      ),
    );
  }
}
