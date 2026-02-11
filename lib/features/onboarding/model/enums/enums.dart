enum AppUserType { serviceProvier, customer, guest, artisan }

extension AppUserTypeExt on AppUserType {
  String getDisplayName() {
    switch (this) {
      case AppUserType.serviceProvier:
        return "Sign Up as Service Provider";
      case AppUserType.guest:
        return "Browse Listings";
      case AppUserType.artisan:
        return "Sign Up as Artisan";
      default: return "Sign Up as Customer";
    }
  }
}