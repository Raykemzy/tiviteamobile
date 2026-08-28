// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artisan_dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtisanDashboardModel _$ArtisanDashboardModelFromJson(
        Map<String, dynamic> json) =>
    ArtisanDashboardModel(
      totalJobs: json['total_jobs'] as num?,
      totalEarnings: readDashboardAmount(json['total_earnings']),
      barChart: json['bar_chart'] == null
          ? null
          : BarChart.fromJson(json['bar_chart'] as Map<String, dynamic>),
      bookingSummary: json['booking_summary'] == null
          ? null
          : BookingSummary.fromJson(
              json['booking_summary'] as Map<String, dynamic>),
      bookingHistoryData: json['booking_history_data'] as List<dynamic>?,
    );

Map<String, dynamic> _$ArtisanDashboardModelToJson(
        ArtisanDashboardModel instance) =>
    <String, dynamic>{
      'total_jobs': instance.totalJobs,
      'total_earnings': instance.totalEarnings,
      'bar_chart': instance.barChart,
      'booking_summary': instance.bookingSummary,
      'booking_history_data': instance.bookingHistoryData,
    };
