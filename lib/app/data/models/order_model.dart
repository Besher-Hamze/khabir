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

class ServiceBreakdown {
  final int quantity;
  final int serviceId;
  final double unitPrice;
  final double commission;
  final double totalPrice;
  final String serviceImage;
  final String serviceTitle;
  final double commissionAmount;
  final String serviceDescription;
  final ServiceCategory? category;

  ServiceBreakdown({
    required this.quantity,
    required this.serviceId,
    required this.unitPrice,
    required this.commission,
    required this.totalPrice,
    required this.serviceImage,
    required this.serviceTitle,
    required this.commissionAmount,
    required this.serviceDescription,
    this.category,
  });

  factory ServiceBreakdown.fromJson(Map<String, dynamic> json) {
    return ServiceBreakdown(
      quantity: json['quantity'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      serviceImage: json['serviceImage'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      serviceDescription: json['serviceDescription'] ?? '',
      category: json['category'] != null
          ? ServiceCategory.fromJson(json['category'])
          : null,
    );
  }
}

class ServiceCategory {
  final int id;
  final String image;
  final String titleAr;
  final String titleEn;
  final String state;

  ServiceCategory({
    required this.id,
    required this.image,
    required this.titleAr,
    required this.titleEn,
    required this.state,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      state: json['state'] ?? '',
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
  final String? payoutDate;
  final String payoutStatus;

  OrderInvoice({
    required this.id,
    required this.orderId,
    this.paymentDate,
    required this.totalAmount,
    required this.discount,
    this.paymentMethod,
    required this.paymentStatus,
    this.payoutDate,
    required this.payoutStatus,
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
      payoutDate: json['payoutDate'],
      payoutStatus: json['payoutStatus'] ?? '',
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
  final String? location;
  final String? locationDetails;
  final double providerAmount;
  final OrderLocation? providerLocation;
  final int quantity;
  final String scheduledDate;
  final double totalAmount;
  final bool isMultipleServices;
  final List<ServiceBreakdown> servicesBreakdown;
  final String? duration;
  final OrderUser user;
  final OrderProvider provider;
  final OrderService service;
  final OrderInvoice? invoice;
  final List<ServiceBreakdown> services;

  OrderModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.orderDate,
    required this.bookingId,
    required this.commissionAmount,
    this.location,
    this.locationDetails,
    required this.providerAmount,
    this.providerLocation,
    required this.quantity,
    required this.scheduledDate,
    required this.totalAmount,
    required this.isMultipleServices,
    required this.servicesBreakdown,
    this.duration,
    required this.user,
    required this.provider,
    required this.service,
    this.invoice,
    required this.services,
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
      location: json['location'],
      locationDetails: json['locationDetails'],
      providerAmount: (json['providerAmount'] ?? 0).toDouble(),
      providerLocation: json['providerLocation'] != null
          ? OrderLocation.fromJson(json['providerLocation'])
          : null,
      quantity: json['quantity'] ?? 0,
      scheduledDate: json['scheduledDate'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      isMultipleServices: json['isMultipleServices'] ?? false,
      servicesBreakdown:
          (json['servicesBreakdown'] as List<dynamic>?)
              ?.map((service) => ServiceBreakdown.fromJson(service))
              .toList() ??
          [],
      duration: json['duration'],
      user: OrderUser.fromJson(json['user'] ?? {}),
      provider: OrderProvider.fromJson(json['provider'] ?? {}),
      service: OrderService.fromJson(json['service'] ?? {}),
      invoice: json['invoice'] != null
          ? OrderInvoice.fromJson(json['invoice'])
          : null,
      services:
          (json['services'] as List<dynamic>?)
              ?.map((service) => ServiceBreakdown.fromJson(service))
              .toList() ??
          [],
    );
  }
}

class OrderLocation {
  final String? address;
  final double? latitude;
  final double? longitude;

  OrderLocation({this.address, this.latitude, this.longitude});

  factory OrderLocation.fromJson(Map<String, dynamic> json) {
    return OrderLocation(
      address: json['address'],
      latitude: json['latitude'] != null ? (json['latitude']).toDouble() : null,
      longitude: json['longitude'] != null
          ? (json['longitude']).toDouble()
          : null,
    );
  }
}
