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
