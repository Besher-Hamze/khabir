import 'package:khabir/app/data/models/category_model.dart';
import 'package:khabir/app/data/models/user_location_model.dart';
import 'service_model.dart';

// =============================================================================
// ENUMS
// =============================================================================

enum ProviderStatus { online, offline, busy }

enum ProviderTier { bronze, silver, gold, platinum }

// =============================================================================
// UNIFIED GLOBAL PROVIDER MODEL - Use this for ALL provider cases
// =============================================================================

class Provider {
  // Basic Info
  final int id;
  final String name;
  final String image;
  final String description;
  final String state;
  final String? city;
  final String phone;
  final String? email;
  final String? location;
  final DateTime createdAt;
  final DateTime? lastSeen;

  // Status & Verification
  final bool isActive;
  final bool isVerified;
  final bool isFeatured;
  final ProviderStatus status;

  // Ratings & Performance
  final double averageRating;
  final int totalRatings;
  final int totalOrders;
  final int completedOrders;
  final int activeServices;
  final double totalRevenue;

  // Ranking & Tier
  final ProviderTier tier;
  final double score;
  final int rank;

  // Legacy rate field (for backward compatibility)
  final double? rate;

  // Relations
  final List<ProviderServiceItem> services;
  final List<ProviderOrder> orders;

  Provider({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.state,
    this.city,
    required this.phone,
    this.email,
    this.location,
    required this.createdAt,
    this.lastSeen,
    this.isActive = false,
    this.isVerified = false,
    this.isFeatured = false,
    this.status = ProviderStatus.offline,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.activeServices = 0,
    this.totalRevenue = 0.0,
    this.tier = ProviderTier.bronze,
    this.score = 0.0,
    this.rank = 0,
    this.rate,
    this.services = const [],
    this.orders = const [],
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: _parseId(json['id']),
      name: json['name'] ?? '',
      image: json['image'] ?? json['profile_image'] ?? '',
      description: json['description'] ?? '',
      state: json['state'] ?? '',
      city: json['city'],
      phone: json['phone'] ?? '',
      email: json['email'],
      location: json['location'],
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      lastSeen: json['lastSeen'] != null || json['last_seen'] != null
          ? DateTime.parse(json['lastSeen'] ?? json['last_seen'])
          : null,
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      isFeatured: json['isFeatured'] ?? json['is_featured'] ?? false,
      status: _parseStatus(json['status']),
      averageRating: (json['averageRating'] ?? json['rating'] ?? 0.0)
          .toDouble(),
      totalRatings: json['totalRatings'] ?? json['reviews_count'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      activeServices: json['activeServices'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      tier: _parseTier(json['tier']),
      score: (json['score'] ?? 0.0).toDouble(),
      rank: json['rank'] ?? 0,
      rate: json['rate']?.toDouble(),
      services: _parseServices(json),
      orders: _parseOrders(json['orders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'state': state,
      'city': city,
      'phone': phone,
      'email': email,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
      'isActive': isActive,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'status': status.name,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'activeServices': activeServices,
      'totalRevenue': totalRevenue,
      'tier': tier.name,
      'score': score,
      'rank': rank,
      'rate': rate,
      'services': services.map((e) => e.toJson()).toList(),
      'orders': orders.map((e) => e.toJson()).toList(),
    };
  }

  // =============================================================================
  // COMPUTED PROPERTIES
  // =============================================================================

  bool get isOnline => status == ProviderStatus.online;
  bool get isOffline => status == ProviderStatus.offline;
  bool get isBusy => status == ProviderStatus.busy;
  bool get isTopTier =>
      tier == ProviderTier.gold || tier == ProviderTier.platinum;

  int get activeServicesCount => services.where((s) => s.isActive).length;
  double get completionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) : 0.0;

  List<String> get topServiceNames =>
      services.where((s) => s.isActive).take(3).map((s) => s.title).toList();

  // =============================================================================
  // HELPER METHODS FOR PARSING
  // =============================================================================

  static int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
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

  static ProviderTier _parseTier(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'silver':
        return ProviderTier.silver;
      case 'gold':
        return ProviderTier.gold;
      case 'platinum':
        return ProviderTier.platinum;
      case 'verified': // Handle API response "verified" tier
        return ProviderTier.gold;
      default:
        return ProviderTier.bronze;
    }
  }

  static List<ProviderServiceItem> _parseServices(Map<String, dynamic> json) {
    // Handle different service field names from different APIs
    final servicesList =
        json['services'] ??
        json['providerServices'] ??
        json['providerService'] ??
        [];

    return (servicesList as List<dynamic>?)
            ?.map((e) => ProviderServiceItem.fromJson(e))
            .toList() ??
        [];
  }

  static List<ProviderOrder> _parseOrders(dynamic ordersData) {
    if (ordersData == null) return [];

    return (ordersData as List<dynamic>?)
            ?.map((e) => ProviderOrder.fromJson(e))
            .toList() ??
        [];
  }

  // =============================================================================
  // CONVERSION METHODS FOR BACKWARD COMPATIBILITY
  // =============================================================================

  /// Convert to legacy ServiceProvider format
  Map<String, dynamic> toServiceProviderJson() {
    return {
      'id': id.toString(), // ServiceProvider uses String ID
      'name': name,
      'phone': phone,
      'email': email,
      'profile_image': image,
      'description': description,
      'state': state,
      'city': city ?? '',
      'rating': averageRating,
      'reviews_count': totalRatings,
      'status': status.name,
      'services': services.map((e) => e.toLegacyProviderServiceJson()).toList(),
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  /// Convert to legacy TopProviderModel format
  Map<String, dynamic> toTopProviderJson() => toJson();

  /// Convert to legacy ProviderApiModel format
  Map<String, dynamic> toProviderApiJson() => toJson();
}

// =============================================================================
// PROVIDER SERVICE ITEM - Unified service model
// =============================================================================

class ProviderServiceItem {
  final int id;
  final int? serviceId;
  final String title;
  final String description;
  final String image;
  final double price;
  final double? offerPrice;
  final bool isActive;
  final double? commission;
  final int? categoryId;

  // Legacy fields for backward compatibility
  final String? providerId;
  final String? subcategoryId;
  final String? nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? unit;
  final int? sortOrder;
  final CategoryModel? category;
  ProviderServiceItem({
    required this.id,
    this.serviceId,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    this.offerPrice,
    this.isActive = true,
    this.commission,
    this.categoryId,
    // Legacy fields
    this.providerId,
    this.subcategoryId,
    this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.unit,
    this.sortOrder,
    this.category,
  });

  factory ProviderServiceItem.fromJson(Map<String, dynamic> json) {
    return ProviderServiceItem(
      id: json['id'] ?? 0,
      serviceId: json['serviceId'],
      title:
          json['title'] ??
          json['name_en'] ??
          json['nameEn'] ??
          json['service']['title'] ??
          json['service']['title'] ??
          '',
      description:
          json['description'] ??
          json['description_en'] ??
          json['descriptionEn'] ??
          json['service']['description'] ??
          '',
      image: json['image'] ?? json['service']['image'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      offerPrice: json['offerPrice']?.toDouble(),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      commission:
          json['commission']?.toDouble() ??
          json['service']['commission']?.toDouble(),
      categoryId: json['categoryId'],
      category: json['category'] != null || json['service']['category'] != null
          ? CategoryModel.fromJson(
              json['category'] ?? json['service']['category'],
            )
          : null,
      // Legacy fields
      providerId: json['provider_id'] ?? json['providerId']?.toString(),
      subcategoryId:
          json['subcategory_id'] ?? json['subcategoryId']?.toString(),
      nameAr: json['name_ar'] ?? json['nameAr'],
      nameEn: json['name_en'] ?? json['nameEn'],
      descriptionAr: json['description_ar'] ?? json['descriptionAr'],
      descriptionEn: json['description_en'] ?? json['descriptionEn'],
      unit: json['unit'],
      sortOrder: json['sort_order'] ?? json['sortOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'offerPrice': offerPrice,
      'isActive': isActive,
      'commission': commission,
      'categoryId': categoryId,
      if (providerId != null) 'providerId': providerId,
      if (subcategoryId != null) 'subcategoryId': subcategoryId,
      if (nameAr != null) 'nameAr': nameAr,
      if (nameEn != null) 'nameEn': nameEn,
      if (descriptionAr != null) 'descriptionAr': descriptionAr,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      if (unit != null) 'unit': unit,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (category != null) 'category': category?.toJson(),
    };
  }

  /// Convert to legacy ProviderService format
  Map<String, dynamic> toLegacyProviderServiceJson() {
    return {
      'id': id.toString(),
      'provider_id': providerId ?? '',
      'subcategory_id': subcategoryId ?? '',
      'name_ar': nameAr ?? title,
      'name_en': nameEn ?? title,
      'description_ar': descriptionAr ?? description,
      'description_en': descriptionEn ?? description,
      'price': price,
      'unit': unit,
      'is_active': isActive,
      'sort_order': sortOrder ?? 0,
    };
  }

  // Computed properties
  bool get hasOffer => offerPrice != null && offerPrice! < price;
  double get displayPrice => offerPrice ?? price;
  double get discountPercentage =>
      hasOffer ? ((price - offerPrice!) / price * 100) : 0.0;
}

// =============================================================================
// PROVIDER ORDER - Unified order model
// =============================================================================

class ProviderOrder {
  final int id;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final String? bookingId;

  ProviderOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.bookingId,
  });

  factory ProviderOrder.fromJson(Map<String, dynamic> json) {
    return ProviderOrder(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      orderDate: DateTime.parse(
        json['orderDate'] ??
            json['order_date'] ??
            DateTime.now().toIso8601String(),
      ),
      bookingId: json['bookingId'] ?? json['booking_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'bookingId': bookingId,
    };
  }
}

// =============================================================================
// API RESPONSE MODELS - Use with unified Provider
// =============================================================================

class ProviderResponse {
  final List<Provider> providers;
  final int total;
  final int? serviceId;
  final String? state;

  ProviderResponse({
    required this.providers,
    required this.total,
    this.serviceId,
    this.state,
  });

  factory ProviderResponse.fromJson(Map<String, dynamic> json) {
    return ProviderResponse(
      providers:
          (json['providers'] as List<dynamic>?)
              ?.map((e) => Provider.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      serviceId: json['serviceId'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providers': providers.map((e) => e.toJson()).toList(),
      'total': total,
      'serviceId': serviceId,
      'state': state,
    };
  }
}

// =============================================================================
// UTILITY CLASS FOR PROVIDER OPERATIONS
// =============================================================================

class ProviderUtils {
  /// Filter active providers
  static List<Provider> filterActive(List<Provider> providers) {
    return providers.where((p) => p.isActive).toList();
  }

  /// Filter verified providers
  static List<Provider> filterVerified(List<Provider> providers) {
    return providers.where((p) => p.isVerified).toList();
  }

  /// Filter by state
  static List<Provider> filterByState(List<Provider> providers, String state) {
    return providers.where((p) => p.state == state).toList();
  }

  /// Filter online providers
  static List<Provider> filterOnline(List<Provider> providers) {
    return providers.where((p) => p.isOnline).toList();
  }

  /// Sort by rank (ascending - lower rank is better)
  static List<Provider> sortByRank(List<Provider> providers) {
    return providers..sort((a, b) => a.rank.compareTo(b.rank));
  }

  /// Sort by rating (descending - higher rating is better)
  static List<Provider> sortByRating(List<Provider> providers) {
    return providers
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
  }

  /// Sort by total orders (descending)
  static List<Provider> sortByPopularity(List<Provider> providers) {
    return providers..sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
  }

  /// Get top providers (active, verified, sorted by rank)
  static List<Provider> getTopProviders(
    List<Provider> providers, {
    int limit = 5,
  }) {
    return sortByRank(
      filterVerified(filterActive(providers)),
    ).take(limit).toList();
  }

  /// Get featured providers
  static List<Provider> getFeaturedProviders(List<Provider> providers) {
    return filterActive(providers.where((p) => p.isFeatured).toList());
  }

  /// Search providers by name
  static List<Provider> searchByName(List<Provider> providers, String query) {
    final lowerQuery = query.toLowerCase();
    return providers
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

// =============================================================================
// TYPE ALIASES FOR BACKWARD COMPATIBILITY
// =============================================================================

typedef TopProviderModel = Provider;
typedef ProviderApiModel = Provider;
typedef ServiceProvider = Provider;
typedef TopProvidersResponse = ProviderResponse;
typedef ProviderApiResponse = ProviderResponse;

// Legacy service types
typedef ProviderServiceApi = ProviderServiceItem;
typedef TopProviderService = ProviderServiceItem;
typedef ProviderService = ProviderServiceItem;
