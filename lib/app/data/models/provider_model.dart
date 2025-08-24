import 'service_model.dart';

enum ProviderStatus { online, offline, busy }

// New model for the API response structure
class ProviderApiResponse {
  final List<ProviderApiModel> providers;
  final int total;
  final int serviceId;

  ProviderApiResponse({
    required this.providers,
    required this.total,
    required this.serviceId,
  });

  factory ProviderApiResponse.fromJson(Map<String, dynamic> json) {
    return ProviderApiResponse(
      providers:
          (json['providers'] as List<dynamic>?)
              ?.map((e) => ProviderApiModel.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providers': providers.map((e) => e.toJson()).toList(),
      'total': total,
      'serviceId': serviceId,
    };
  }
}

// New model for individual provider from API
class ProviderApiModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final String state;
  final String phone;
  final String? location;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final List<ProviderServiceApi> providerServices;

  ProviderApiModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.state,
    required this.phone,
    this.location,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.providerServices,
  });

  factory ProviderApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderApiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      state: json['state'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'],
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      providerServices:
          (json['providerServices'] as List<dynamic>?)
              ?.map((e) => ProviderServiceApi.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'state': state,
      'phone': phone,
      'location': location,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'providerServices': providerServices.map((e) => e.toJson()).toList(),
    };
  }
}

// New model for provider service from API
class ProviderServiceApi {
  final double price;
  final bool isActive;

  ProviderServiceApi({required this.price, required this.isActive});

  factory ProviderServiceApi.fromJson(Map<String, dynamic> json) {
    return ProviderServiceApi(
      price: (json['price'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'price': price, 'isActive': isActive};
  }
}

class ServiceProvider {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImage;
  final String? description;
  final String state;
  final String city;
  final double rating;
  final int reviewsCount;
  final ProviderStatus status;
  final List<ProviderService> services;
  final bool isVerified;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? lastSeen;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImage,
    this.description,
    required this.state,
    required this.city,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.status = ProviderStatus.offline,
    this.services = const [],
    this.isVerified = false,
    this.isFeatured = false,
    required this.createdAt,
    this.lastSeen,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      profileImage: json['profile_image'],
      description: json['description'],
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      status: _parseStatus(json['status']),
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ProviderService.fromJson(e))
              .toList() ??
          [],
      isVerified: json['is_verified'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profile_image': profileImage,
      'description': description,
      'state': state,
      'city': city,
      'rating': rating,
      'reviews_count': reviewsCount,
      'status': status.name,
      'services': services.map((e) => e.toJson()).toList(),
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  static ProviderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
        return ProviderStatus.online;
      case 'busy':
        return ProviderStatus.busy;
      default:
        return ProviderStatus.offline;
    }
  }

  bool get isOnline => status == ProviderStatus.online;
  bool get isOffline => status == ProviderStatus.offline;
  bool get isBusy => status == ProviderStatus.busy;
}

class ProviderService {
  final String id;
  final String providerId;
  final String subcategoryId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final String? unit;
  final bool isActive;
  final int sortOrder;

  ProviderService({
    required this.id,
    required this.providerId,
    required this.subcategoryId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    this.unit,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['id'] ?? '',
      providerId: json['provider_id'] ?? '',
      subcategoryId: json['subcategory_id'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      price: (json['price'] ?? 0.0).toDouble(),
      unit: json['unit'],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'subcategory_id': subcategoryId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'price': price,
      'unit': unit,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

// New model for provider services response
class ProviderServicesResponse {
  final int categoryId;
  final String categoryName;
  final int providerId;
  final String providerName;
  final List<ProviderServiceItem> services;
  final int total;

  ProviderServicesResponse({
    required this.categoryId,
    required this.categoryName,
    required this.providerId,
    required this.providerName,
    required this.services,
    required this.total,
  });

  factory ProviderServicesResponse.fromJson(Map<String, dynamic> json) {
    return ProviderServicesResponse(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      providerId: json['providerId'] ?? 0,
      providerName: json['providerName'] ?? '',
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ProviderServiceItem.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'providerId': providerId,
      'providerName': providerName,
      'services': services.map((e) => e.toJson()).toList(),
      'total': total,
    };
  }
}

// New model for individual provider service item
class ProviderServiceItem {
  final int id;
  final String title;
  final String description;
  final String image;
  final double commission;
  final int categoryId;
  final ProviderServicePrice providerService;

  ProviderServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.commission,
    required this.categoryId,
    required this.providerService,
  });

  factory ProviderServiceItem.fromJson(Map<String, dynamic> json) {
    return ProviderServiceItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      commission: (json['commission'] ?? 0.0).toDouble(),
      categoryId: json['categoryId'] ?? 0,
      providerService: ProviderServicePrice.fromJson(
        json['providerService'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'commission': commission,
      'categoryId': categoryId,
      'providerService': providerService.toJson(),
    };
  }
}

// New model for provider service price
class ProviderServicePrice {
  final int id;
  final double price;
  final bool isActive;

  ProviderServicePrice({
    required this.id,
    required this.price,
    required this.isActive,
  });

  factory ProviderServicePrice.fromJson(Map<String, dynamic> json) {
    return ProviderServicePrice(
      id: json['id'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'price': price, 'isActive': isActive};
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

// New model for user location
class UserLocation {
  final double latitude;
  final double longitude;
  final String address;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }
}

// New model for service request API response
class ServiceRequestResponse {
  final int id;
  final String bookingId;
  final String status;
  final String scheduledDate;
  final String location;
  final String locationDetails;
  final UserLocation userLocation;
  final String notes;
  final List<ServiceResponseItem> services;
  final double subtotal;
  final double totalCommission;
  final double totalAmount;
  final ServiceRequestProvider provider;

  ServiceRequestResponse({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.scheduledDate,
    required this.location,
    required this.locationDetails,
    required this.userLocation,
    required this.notes,
    required this.services,
    required this.subtotal,
    required this.totalCommission,
    required this.totalAmount,
    required this.provider,
  });

  factory ServiceRequestResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRequestResponse(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'] ?? '',
      status: json['status'] ?? '',
      scheduledDate: json['scheduledDate'] ?? '',
      location: json['location'] ?? '',
      locationDetails: json['locationDetails'] ?? '',
      userLocation: UserLocation.fromJson(json['userLocation'] ?? {}),
      notes: json['notes'] ?? '',
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceResponseItem.fromJson(e))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      totalCommission: (json['totalCommission'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      provider: ServiceRequestProvider.fromJson(json['provider'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'status': status,
      'scheduledDate': scheduledDate,
      'location': location,
      'locationDetails': locationDetails,
      'userLocation': userLocation.toJson(),
      'notes': notes,
      'services': services.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'totalCommission': totalCommission,
      'totalAmount': totalAmount,
      'provider': provider.toJson(),
    };
  }
}

// New model for service response item
class ServiceResponseItem {
  final int serviceId;
  final String serviceTitle;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  ServiceResponseItem({
    required this.serviceId,
    required this.serviceTitle,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory ServiceResponseItem.fromJson(Map<String, dynamic> json) {
    return ServiceResponseItem(
      serviceId: json['serviceId'] ?? 0,
      serviceTitle: json['serviceTitle'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

// New model for service request provider
class ServiceRequestProvider {
  final int id;
  final String name;
  final String phone;
  final String image;

  ServiceRequestProvider({
    required this.id,
    required this.name,
    required this.phone,
    required this.image,
  });

  factory ServiceRequestProvider.fromJson(Map<String, dynamic> json) {
    return ServiceRequestProvider(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'image': image};
  }
}
