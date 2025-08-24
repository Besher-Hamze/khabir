import 'package:khabir/app/data/models/user_location_model.dart';

import 'category_model.dart';

class ServiceModel {
  final int id;
  final String image;
  final String title;
  final String description;
  final double commission;
  final String whatsapp;
  final int categoryId;
  final CategoryModel category;

  ServiceModel({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.commission,
    required this.whatsapp,
    required this.categoryId,
    required this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      commission: (json['commission'] ?? 0.0).toDouble(),
      whatsapp: json['whatsapp'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      category: CategoryModel.fromJson(json['category'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'description': description,
      'commission': commission,
      'whatsapp': whatsapp,
      'categoryId': categoryId,
      'category': category.toJson(),
    };
  }

  // Check if service has an image
  bool get hasImage => image.isNotEmpty;

  // Get image URL with base URL
  String getImageUrl(String baseUrl) {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return '$baseUrl$image';
  }

  // Format commission for display
  String get formattedCommission => 'SAR $commission';
}

class ServiceCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  final String? image;
  final List<ServiceSubcategory> subcategories;
  final bool isActive;
  final int sortOrder;

  ServiceCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.image,
    this.subcategories = const [],
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar'] ?? json['nameAr'] ?? '',
      nameEn: json['name_en'] ?? json['nameEn'] ?? '',
      descriptionAr: json['description_ar'] ?? json['descriptionAr'],
      descriptionEn: json['description_en'] ?? json['descriptionEn'],
      icon: json['icon'],
      image: json['image'],
      subcategories:
          (json['subcategories'] as List<dynamic>?)
              ?.map((e) => ServiceSubcategory.fromJson(e))
              .toList() ??
          [],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'icon': icon,
      'image': image,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

class ServiceSubcategory {
  final String id;
  final String categoryId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  final String? image;
  final double? basePrice;
  final bool isActive;
  final int sortOrder;

  ServiceSubcategory({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.image,
    this.basePrice,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ServiceSubcategory.fromJson(Map<String, dynamic> json) {
    return ServiceSubcategory(
      id: json['id']?.toString() ?? '',
      categoryId:
          json['category_id']?.toString() ??
          json['categoryId']?.toString() ??
          '',
      nameAr: json['name_ar'] ?? json['nameAr'] ?? '',
      nameEn: json['name_en'] ?? json['nameEn'] ?? '',
      descriptionAr: json['description_ar'] ?? json['descriptionAr'],
      descriptionEn: json['description_en'] ?? json['descriptionEn'],
      icon: json['icon'],
      image: json['image'],
      basePrice:
          json['base_price']?.toDouble() ?? json['basePrice']?.toDouble(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'icon': icon,
      'image': image,
      'base_price': basePrice,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

// Offer Model
class Offer {
  final String id;
  final String providerId;
  final String serviceId;
  final String title;
  final String description;
  final double originalPrice;
  final double offerPrice;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ServiceSubcategory? service;

  Offer({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.offerPrice,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.service,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0.0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      service: json['service'] != null
          ? ServiceSubcategory.fromJson(json['service'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'serviceId': serviceId,
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'offerPrice': offerPrice,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'service': service?.toJson(),
    };
  }

  double get discountPercentage =>
      ((originalPrice - offerPrice) / originalPrice * 100).roundToDouble();
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActiveNow => isActive && !isExpired;
}

// Provider Rating Model
class ProviderRating {
  final String id;
  final String providerId;
  final String userId;
  final String orderId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final String? userProfileImage;

  ProviderRating({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.orderId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.userProfileImage,
  });

  factory ProviderRating.fromJson(Map<String, dynamic> json) {
    return ProviderRating(
      id: json['id']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'userId': userId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userName': userName,
      'userProfileImage': userProfileImage,
    };
  }
}

// Create Rating Request Model
class CreateRatingRequest {
  final String providerId;
  final String orderId;
  final double rating;
  final String? comment;

  CreateRatingRequest({
    required this.providerId,
    required this.orderId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    };
  }
}

// Update Rating Request Model
class UpdateRatingRequest {
  final double rating;
  final String? comment;

  UpdateRatingRequest({required this.rating, this.comment});

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'comment': comment};
  }
}

// New model for service request API request
class ServiceRequestRequest {
  final int providerId;
  final List<ServiceRequestItem> services;
  final String scheduledDate;
  final String location;
  final String locationDetails;
  final UserLocation userLocation;
  final String notes;

  ServiceRequestRequest({
    required this.providerId,
    required this.services,
    required this.scheduledDate,
    required this.location,
    required this.locationDetails,
    required this.userLocation,
    required this.notes,
  });

  factory ServiceRequestRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequestRequest(
      providerId: json['providerId'] ?? 0,
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceRequestItem.fromJson(e))
              .toList() ??
          [],
      scheduledDate: json['scheduledDate'] ?? '',
      location: json['location'] ?? '',
      locationDetails: json['locationDetails'] ?? '',
      userLocation: UserLocation.fromJson(json['userLocation'] ?? {}),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'services': services.map((e) => e.toJson()).toList(),
      'scheduledDate': scheduledDate,
      'location': location,
      'locationDetails': locationDetails,
      'userLocation': userLocation.toJson(),
      'notes': notes,
    };
  }
}

// New model for service request item
class ServiceRequestItem {
  final int serviceId;
  final int quantity;

  ServiceRequestItem({required this.serviceId, required this.quantity});

  factory ServiceRequestItem.fromJson(Map<String, dynamic> json) {
    return ServiceRequestItem(
      serviceId: json['serviceId'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'serviceId': serviceId, 'quantity': quantity};
  }
}
