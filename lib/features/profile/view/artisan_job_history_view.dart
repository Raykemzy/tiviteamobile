import 'package:flutter/widgets.dart';
import 'package:tivi_tea/features/history/view/history_view.dart';

/// An artisan's completed and upcoming jobs.
///
/// Jobs and bookings are the same records on the backend — `/bookings/list`
/// serves every role — so this reuses the booking history list rather than
/// duplicating it. It previously rendered an empty Column.
class JobHistoryView extends StatelessWidget {
  const JobHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const HistoryView(title: 'Job History');
  }
}
