// Offer Models
class OfferResponse {
  final List<OfferModel> offers;

  OfferResponse({required this.offers});

  factory OfferResponse.fromJson(Map<String, dynamic> json) {
    return OfferResponse(
      offers:
          (json as List<dynamic>?)
              ?.map((e) => OfferModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OfferModel {
  final int id;
  final int providerId;
  final int serviceId;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final bool isActive;
  final double offerPrice;
  final double originalPrice;
  final OfferProvider provider;
  final OfferService service;

  OfferModel({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.isActive,
    required this.offerPrice,
    required this.originalPrice,
    required this.provider,
    required this.service,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? 0,
      providerId: json['providerId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      provider: OfferProvider.fromJson(json['provider'] ?? {}),
      service: OfferService.fromJson(json['service'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'serviceId': serviceId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'isActive': isActive,
      'offerPrice': offerPrice,
      'originalPrice': originalPrice,
      'provider': provider.toJson(),
      'service': service.toJson(),
    };
  }
}

class OfferProvider {
  final int id;
  final String name;
  final String image;
  final bool isVerified;
  final bool isActive;

  OfferProvider({
    required this.id,
    required this.name,
    required this.image,
    required this.isVerified,
    required this.isActive,
  });

  factory OfferProvider.fromJson(Map<String, dynamic> json) {
    return OfferProvider(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }
}

class OfferService {
  final int id;
  final String title;
  final String description;
  final String image;
  OfferService({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory OfferService.fromJson(Map<String, dynamic> json) {
    return OfferService(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
    };
  }
}
