class UserProfileResponse {
  final UserProfileModel user;
  final SystemInfoModel systemInfo;

  UserProfileResponse({required this.user, required this.systemInfo});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      user: UserProfileModel.fromJson(json['user'] ?? {}),
      systemInfo: SystemInfoModel.fromJson(json['systemInfo'] ?? {}),
    );
  }
}

class UserProfileModel {
  final int id;
  final String name;
  final String? email;
  final String role;
  final String image;
  final String address;
  final String phone;
  final String state;
  final bool isActive;
  final String? officialDocuments;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    required this.image,
    required this.address,
    required this.phone,
    required this.state,
    required this.isActive,
    this.officialDocuments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      role: json['role'] ?? '',
      image: json['image'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
      isActive: json['isActive'] ?? false,
      officialDocuments: json['officialDocuments'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'image': image,
      'address': address,
      'phone': phone,
      'state': state,
      'isActive': isActive,
      'officialDocuments': officialDocuments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SystemInfoModel {
  final SocialMediaModel socialMedia;
  final LegalDocumentsModel legalDocuments;
  final SupportModel support;

  SystemInfoModel({
    required this.socialMedia,
    required this.legalDocuments,
    required this.support,
  });

  factory SystemInfoModel.fromJson(Map<String, dynamic> json) {
    return SystemInfoModel(
      socialMedia: SocialMediaModel.fromJson(json['socialMedia'] ?? {}),
      legalDocuments: LegalDocumentsModel.fromJson(
        json['legalDocuments'] ?? {},
      ),
      support: SupportModel.fromJson(json['support'] ?? {}),
    );
  }
}

class SocialMediaModel {
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final String? snapchat;

  SocialMediaModel({
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.tiktok,
    this.snapchat,
  });

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaModel(
      whatsapp: json['whatsapp'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      tiktok: json['tiktok'],
      snapchat: json['snapchat'],
    );
  }
}

class LegalDocumentsModel {
  final String? termsEn;
  final String? termsAr;
  final String? privacyEn;
  final String? privacyAr;

  LegalDocumentsModel({
    this.termsEn,
    this.termsAr,
    this.privacyEn,
    this.privacyAr,
  });

  factory LegalDocumentsModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentsModel(
      termsEn: json['terms_en'],
      termsAr: json['terms_ar'],
      privacyEn: json['privacy_en'],
      privacyAr: json['privacy_ar'],
    );
  }
}

class SupportModel {
  final String? whatsappSupport;

  SupportModel({this.whatsappSupport});

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    return SupportModel(whatsappSupport: json['whatsapp_support']);
  }
}

// Request model for updating user profile
class UpdateProfileRequest {
  final String? name;
  final String? state;

  UpdateProfileRequest({this.name, this.state});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (state != null) data['state'] = state;

    return data;
  }
}
