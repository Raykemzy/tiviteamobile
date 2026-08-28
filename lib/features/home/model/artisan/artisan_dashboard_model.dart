import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/features/home/model/service_provider/service_provider_dashboard_model.dart';

part 'artisan_dashboard_model.g.dart';

/// Shape of `GET /dashboard/artisan`.
///
/// Deliberately distinct from [ServiceProviderDashboardModel]: an artisan has
/// jobs and earnings, not listings and bookings, so the two dashboards do not
/// share a payload. [BarChart] and [BookingSummary] are shared because the
/// backend returns them identically for both.
@JsonSerializable()
class ArtisanDashboardModel {
  @JsonKey(name: 'total_jobs')
  final num? totalJobs;

  /// The backend sends this as a plain number for artisans, but as a
  /// pre-formatted string ("2K") on the partner dashboard. Parsed leniently so
  /// a future formatting change on the backend cannot break the screen.
  @JsonKey(name: 'total_earnings', fromJson: readDashboardAmount)
  final String? totalEarnings;

  @JsonKey(name: 'bar_chart')
  final BarChart? barChart;

  @JsonKey(name: 'booking_summary')
  final BookingSummary? bookingSummary;

  @JsonKey(name: 'booking_history_data')
  final List<dynamic>? bookingHistoryData;

  ArtisanDashboardModel({
    this.totalJobs,
    this.totalEarnings,
    this.barChart,
    this.bookingSummary,
    this.bookingHistoryData,
  });

  factory ArtisanDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$ArtisanDashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArtisanDashboardModelToJson(this);
}
