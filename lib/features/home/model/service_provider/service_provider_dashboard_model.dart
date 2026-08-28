import 'package:json_annotation/json_annotation.dart';

part 'service_provider_dashboard_model.g.dart';

@JsonSerializable()
class ServiceProviderDashboardModel {
  @JsonKey(name: 'total_bookings')
  final num? totalBookings;
  @JsonKey(name: 'total_listings')
  final num? totalListings;
  @JsonKey(name: 'bar_chart')
  final BarChart? barChart;
  /// The backend returns this pre-formatted for display — "2K", not 2000 —
  /// so it cannot be parsed as a number. It was previously typed `double?`,
  /// which made json_serializable emit `as num?`, throw a TypeError on every
  /// response, and leave the whole dashboard silently blank.
  @JsonKey(name: 'total_revenue', fromJson: readDashboardAmount)
  final String? totalRevenue;
  @JsonKey(name: 'booking_summary')
  final BookingSummary? bookingSummary;
  @JsonKey(name: 'booking_history_data')
  final List<dynamic>? bookingHistoryData;

  ServiceProviderDashboardModel({
    this.totalBookings,
    this.totalListings,
    this.barChart,
    this.totalRevenue,
    this.bookingSummary,
    this.bookingHistoryData,
  });

  factory ServiceProviderDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceProviderDashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceProviderDashboardModelToJson(this);
}

@JsonSerializable()
class BarChart {
  @JsonKey(name: 'this year')
  final List<num>? thisYear;

  @JsonKey(name: 'this month')
  final List<num>? thisMonth;

  @JsonKey(name: 'this_week')
  final List<num>? thisWeek;

  BarChart({
    this.thisYear,
    this.thisMonth,
    this.thisWeek,
  });

  factory BarChart.fromJson(Map<String, dynamic> json) =>
      _$BarChartFromJson(json);

  Map<String, dynamic> toJson() => _$BarChartToJson(this);
}

@JsonSerializable()
class BookingSummary {
  final String? incoming;
  final String? ongoing;
  final String? completed;

  BookingSummary({
    this.incoming,
    this.ongoing,
    this.completed,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) =>
      _$BookingSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$BookingSummaryToJson(this);
}
/// Reads a dashboard money/count field that the backend may send either as a
/// number or as an already-formatted string. Always yields a display string.
String? readDashboardAmount(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
  return value.toString();
}
