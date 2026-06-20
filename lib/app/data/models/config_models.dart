class AppConfig {
  final String appName;
  final int latestVersion;
  final bool forceUpdate;
  final bool maintenance;
  final String maintenanceMessage;
  final String updateMessage;
  final String playStoreUrl;

  AppConfig({
    required this.appName,
    required this.latestVersion,
    required this.forceUpdate,
    required this.maintenance,
    required this.maintenanceMessage,
    required this.updateMessage,
    required this.playStoreUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'latestVersion': latestVersion,
      'forceUpdate': forceUpdate,
      'maintenance': maintenance,
      'maintenanceMessage': maintenanceMessage,
      'updateMessage': updateMessage,
      'playStoreUrl': playStoreUrl,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      appName: map['appName'] ?? '',
      latestVersion: (map['latestVersion'] ?? 0).toInt(),
      forceUpdate: map['forceUpdate'] ?? false,
      maintenance: map['maintenance'] ?? false,
      maintenanceMessage: map['maintenanceMessage'] ?? '',
      updateMessage: map['updateMessage'] ?? '',
      playStoreUrl: map['playStoreUrl'] ?? '',
    );
  }
}

class DonationConfig {
  final String bkash;
  final String nagad;
  final String rocket;
  final String buyMeCoffee;
  final String githubSponsors;

  DonationConfig({
    required this.bkash,
    required this.nagad,
    required this.rocket,
    required this.buyMeCoffee,
    required this.githubSponsors,
  });

  bool get isEmpty =>
      bkash.isEmpty &&
      nagad.isEmpty &&
      rocket.isEmpty &&
      buyMeCoffee.isEmpty &&
      githubSponsors.isEmpty;

  bool get isNotEmpty => !isEmpty;

  Map<String, String> toMap() {
    return {
      'bkash': bkash,
      'nagad': nagad,
      'rocket': rocket,
      'buy_me_coffee': buyMeCoffee,
      'github_sponsors': githubSponsors,
    }..removeWhere((key, value) => value.isEmpty);
  }

  factory DonationConfig.fromMap(Map<String, dynamic> map) {
    return DonationConfig(
      bkash: map['bkash'] ?? '',
      nagad: map['nagad'] ?? '',
      rocket: map['rocket'] ?? '',
      buyMeCoffee: map['buyMeCoffee'] ?? '',
      githubSponsors: map['githubSponsors'] ?? '',
    );
  }

  factory DonationConfig.empty() => DonationConfig(
        bkash: '',
        nagad: '',
        rocket: '',
        buyMeCoffee: '',
        githubSponsors: '',
      );
}

class SocialConfig {
  final String facebook;
  final String twitter;
  final String instagram;
  final String youtube;
  final String linkedin;

  SocialConfig({
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.youtube,
    required this.linkedin,
  });

  bool get isEmpty =>
      facebook.isEmpty &&
      twitter.isEmpty &&
      instagram.isEmpty &&
      youtube.isEmpty &&
      linkedin.isEmpty;

  bool get isNotEmpty => !isEmpty;

  Map<String, String> toMap() {
    return {
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'youtube': youtube,
      'linkedin': linkedin,
    }..removeWhere((key, value) => value.isEmpty);
  }

  factory SocialConfig.fromMap(Map<String, dynamic> map) {
    return SocialConfig(
      facebook: map['facebook'] ?? '',
      twitter: map['twitter'] ?? '',
      instagram: map['instagram'] ?? '',
      youtube: map['youtube'] ?? '',
      linkedin: map['linkedin'] ?? '',
    );
  }

  factory SocialConfig.empty() => SocialConfig(
        facebook: '',
        twitter: '',
        instagram: '',
        youtube: '',
        linkedin: '',
      );
}

class ContactConfig {
  final String email;
  final String website;
  final String privacyPolicy;
  final String termsOfUse;

  ContactConfig({
    required this.email,
    required this.website,
    required this.privacyPolicy,
    required this.termsOfUse,
  });

  bool get isEmpty =>
      email.isEmpty && website.isEmpty && privacyPolicy.isEmpty && termsOfUse.isEmpty;

  bool get isNotEmpty => !isEmpty;

  Map<String, String> toMap() {
    return {
      'email': email,
      'website': website,
      'privacy_policy': privacyPolicy,
      'terms_of_use': termsOfUse,
    }..removeWhere((key, value) => value.isEmpty);
  }

  factory ContactConfig.fromMap(Map<String, dynamic> map) {
    return ContactConfig(
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      privacyPolicy: map['privacyPolicy'] ?? '',
      termsOfUse: map['termsOfUse'] ?? '',
    );
  }

  factory ContactConfig.empty() => ContactConfig(
        email: '',
        website: '',
        privacyPolicy: '',
        termsOfUse: '',
      );
}

class AboutConfig {
  final String developerName;
  final String publisherName;
  final String githubRepo;
  final String portfolioUrl;

  AboutConfig({
    required this.developerName,
    required this.publisherName,
    required this.githubRepo,
    required this.portfolioUrl,
  });

  bool get isEmpty =>
      developerName.isEmpty &&
      publisherName.isEmpty &&
      githubRepo.isEmpty &&
      portfolioUrl.isEmpty;

  bool get isNotEmpty => !isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'developerName': developerName,
      'publisherName': publisherName,
      'githubRepo': githubRepo,
      'portfolioUrl': portfolioUrl,
    };
  }

  factory AboutConfig.fromMap(Map<String, dynamic> map) {
    return AboutConfig(
      developerName: map['developerName'] ?? '',
      publisherName: map['publisherName'] ?? '',
      githubRepo: map['githubRepo'] ?? '',
      portfolioUrl: map['portfolioUrl'] ?? '',
    );
  }

  factory AboutConfig.empty() => AboutConfig(
        developerName: '',
        publisherName: '',
        githubRepo: '',
        portfolioUrl: '',
      );
}

class SupportConfig {
  final DonationConfig donation;
  final SocialConfig social;
  final ContactConfig contact;
  final AboutConfig about;

  SupportConfig({
    required this.donation,
    required this.social,
    required this.contact,
    required this.about,
  });

  bool get isEmpty =>
      donation.isEmpty && social.isEmpty && contact.isEmpty && about.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'donation': donation.toMap(),
      'social': social.toMap(),
      'contact': contact.toMap(),
      'about': about.toMap(),
    };
  }

  factory SupportConfig.fromMap(Map<String, dynamic> map) {
    return SupportConfig(
      donation: map['donation'] != null ? DonationConfig.fromMap(map['donation']) : DonationConfig.empty(),
      social: map['social'] != null ? SocialConfig.fromMap(map['social']) : SocialConfig.empty(),
      contact: map['contact'] != null ? ContactConfig.fromMap(map['contact']) : ContactConfig.empty(),
      about: map['about'] != null ? AboutConfig.fromMap(map['about']) : AboutConfig.empty(),
    );
  }

  factory SupportConfig.empty() => SupportConfig(
        donation: DonationConfig.empty(),
        social: SocialConfig.empty(),
        contact: ContactConfig.empty(),
        about: AboutConfig.empty(),
      );
}
