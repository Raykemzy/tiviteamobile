import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum EntityType { partner, client, artisan }

enum KYCStatus { pending, approved, rejected }

enum DocumentType { nin, passport, votersCard, driverLicense }

extension DocumentTypeExt on DocumentType {
  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere((e) => e.getDisplayName() == value);
  }

  static List<String> get stringValues =>
      DocumentType.values.map((value) => value.getDisplayName()).toList();

  String getDisplayName() {
    switch (this) {
      case DocumentType.nin:
        return "National Identity Number (NIN)";
      case DocumentType.passport:
        return "International Passport";
      case DocumentType.votersCard:
        return "Voters Card";
      case DocumentType.driverLicense:
        return "Driver's License";
    }
  }
}
