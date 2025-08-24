// Banner Models
class BannerResponse {
  final List<BannerModel> banners;

  BannerResponse({required this.banners});

  factory BannerResponse.fromJson(List<dynamic> json) {
    return BannerResponse(
      banners: json.map((e) => BannerModel.fromJson(e)).toList(),
    );
  }
}

class BannerModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String linkType; // 'external' or 'provider'
  final String? externalLink;
  final int? providerId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.linkType,
    this.externalLink,
    this.providerId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      linkType: json['linkType'] ?? 'external',
      externalLink: json['externalLink'],
      providerId: json['providerId'],
      isActive: json['isActive'] ?? false,
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
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'linkType': linkType,
      'externalLink': externalLink,
      'providerId': providerId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
