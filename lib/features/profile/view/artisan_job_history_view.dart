import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';

class JobHistoryView extends StatelessWidget {
  const JobHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbar: const CustomAppBar(
        homeScreenAppBar: true,
        title: 'Job History',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
