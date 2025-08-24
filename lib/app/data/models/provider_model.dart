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

// Order Models
class OrderResponse {
  final List<OrderModel> orders;

  OrderResponse({required this.orders});

  factory OrderResponse.fromJson(List<dynamic> json) {
    return OrderResponse(
      orders: json.map((order) => OrderModel.fromJson(order)).toList(),
    );
  }
}

class OrderModel {
  final int id;
  final int userId;
  final int providerId;
  final int serviceId;
  final String status;
  final String orderDate;
  final String bookingId;
  final double commissionAmount;
  final String location;
  final String locationDetails;
  final double providerAmount;
  final OrderLocation providerLocation;
  final int quantity;
  final String scheduledDate;
  final double totalAmount;
  final OrderUser user;
  final OrderProvider provider;
  final OrderService service;
  final OrderInvoice invoice;

  OrderModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.orderDate,
    required this.bookingId,
    required this.commissionAmount,
    required this.location,
    required this.locationDetails,
    required this.providerAmount,
    required this.providerLocation,
    required this.quantity,
    required this.scheduledDate,
    required this.totalAmount,
    required this.user,
    required this.provider,
    required this.service,
    required this.invoice,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      providerId: json['providerId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      status: json['status'] ?? '',
      orderDate: json['orderDate'] ?? '',
      bookingId: json['bookingId'] ?? '',
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      locationDetails: json['locationDetails'] ?? '',
      providerAmount: (json['providerAmount'] ?? 0).toDouble(),
      providerLocation: OrderLocation.fromJson(json['providerLocation'] ?? {}),
      quantity: json['quantity'] ?? 0,
      scheduledDate: json['scheduledDate'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      user: OrderUser.fromJson(json['user'] ?? {}),
      provider: OrderProvider.fromJson(json['provider'] ?? {}),
      service: OrderService.fromJson(json['service'] ?? {}),
      invoice: OrderInvoice.fromJson(json['invoice'] ?? {}),
    );
  }
}

class OrderLocation {
  final String address;
  final double latitude;
  final double longitude;

  OrderLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory OrderLocation.fromJson(Map<String, dynamic> json) {
    return OrderLocation(
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

class OrderUser {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final double? latitude;
  final double? longitude;

  OrderUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.latitude,
    this.longitude,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      latitude: json['latitude'] != null ? (json['latitude']).toDouble() : null,
      longitude: json['longitude'] != null
          ? (json['longitude']).toDouble()
          : null,
    );
  }
}

class OrderProvider {
  final int id;
  final String name;
  final String phone;
  final String image;

  OrderProvider({
    required this.id,
    required this.name,
    required this.phone,
    required this.image,
  });

  factory OrderProvider.fromJson(Map<String, dynamic> json) {
    return OrderProvider(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class OrderService {
  final int id;
  final String title;
  final String description;
  final String image;

  OrderService({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory OrderService.fromJson(Map<String, dynamic> json) {
    return OrderService(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class OrderInvoice {
  final int id;
  final int orderId;
  final String? paymentDate;
  final double totalAmount;
  final double discount;
  final String? paymentMethod;
  final String paymentStatus;
  final bool isVerified;
  final String? payoutDate;
  final String payoutStatus;
  final String? verifiedAt;
  final String? verifiedBy;

  OrderInvoice({
    required this.id,
    required this.orderId,
    this.paymentDate,
    required this.totalAmount,
    required this.discount,
    this.paymentMethod,
    required this.paymentStatus,
    required this.isVerified,
    this.payoutDate,
    required this.payoutStatus,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory OrderInvoice.fromJson(Map<String, dynamic> json) {
    return OrderInvoice(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      paymentDate: json['paymentDate'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'] ?? '',
      isVerified: json['isVerified'] ?? false,
      payoutDate: json['payoutDate'],
      payoutStatus: json['payoutStatus'] ?? '',
      verifiedAt: json['verifiedAt'],
      verifiedBy: json['verifiedBy'],
    );
  }
}

// Top Providers Models
class TopProvidersResponse {
  final List<TopProviderModel> providers;

  TopProvidersResponse({required this.providers});

  factory TopProvidersResponse.fromJson(Map<String, dynamic> json) {
    return TopProvidersResponse(
      providers:
          (json['providers'] as List<dynamic>?)
              ?.map((e) => TopProviderModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TopProviderModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final String state;
  final String phone;
  final bool isActive;
  final bool isVerified;
  final String email;
  final List<ProviderOrder> orders;
  final List<TopProviderService> providerServices;
  final double averageRating;
  final int totalRatings;
  final int totalOrders;
  final int completedOrders;
  final double totalRevenue;
  final int activeServices;
  final String tier;
  final int score;
  final int rank;

  TopProviderModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.state,
    required this.phone,
    required this.isActive,
    required this.isVerified,
    required this.email,
    required this.orders,
    required this.providerServices,
    required this.averageRating,
    required this.totalRatings,
    required this.totalOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.activeServices,
    required this.tier,
    required this.score,
    required this.rank,
  });

  factory TopProviderModel.fromJson(Map<String, dynamic> json) {
    return TopProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      state: json['state'] ?? '',
      phone: json['phone'] ?? '',
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      email: json['email'] ?? '',
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => ProviderOrder.fromJson(e))
              .toList() ??
          [],
      providerServices:
          (json['providerServices'] as List<dynamic>?)
              ?.map((e) => TopProviderService.fromJson(e))
              .toList() ??
          [],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      activeServices: json['activeServices'] ?? 0,
      tier: json['tier'] ?? '',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}

class ProviderOrder {
  final int id;
  final String status;
  final double totalAmount;
  final DateTime orderDate;

  ProviderOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
  });

  factory ProviderOrder.fromJson(Map<String, dynamic> json) {
    return ProviderOrder(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      orderDate: DateTime.parse(
        json['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class TopProviderService {
  final int id;
  final int providerId;
  final int serviceId;
  final bool isActive;
  final double price;
  final TopService service;

  TopProviderService({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.isActive,
    required this.price,
    required this.service,
  });

  factory TopProviderService.fromJson(Map<String, dynamic> json) {
    return TopProviderService(
      id: json['id'] ?? 0,
      providerId: json['providerId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      isActive: json['isActive'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      service: TopService.fromJson(json['service'] ?? {}),
    );
  }
}

class TopService {
  final int id;
  final String image;
  final String title;
  final String description;
  final double commission;
  final String whatsapp;
  final int? categoryId;
  final TopCategory? category;

  TopService({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.commission,
    required this.whatsapp,
    this.categoryId,
    this.category,
  });

  factory TopService.fromJson(Map<String, dynamic> json) {
    return TopService(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      commission: (json['commission'] ?? 0).toDouble(),
      whatsapp: json['whatsapp'] ?? '',
      categoryId: json['categoryId'],
      category: json['category'] != null
          ? TopCategory.fromJson(json['category'])
          : null,
    );
  }
}

class TopCategory {
  final int id;
  final String image;
  final String titleAr;
  final String titleEn;
  final String state;

  TopCategory({
    required this.id,
    required this.image,
    required this.titleAr,
    required this.titleEn,
    required this.state,
  });

  factory TopCategory.fromJson(Map<String, dynamic> json) {
    return TopCategory(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      state: json['state'] ?? '',
    );
  }
}

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
      'providerId': id,
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
