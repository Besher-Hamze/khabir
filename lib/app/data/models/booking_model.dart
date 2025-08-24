import 'service_model.dart';
import 'provider_model.dart';

class Booking {
  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final DateTime scheduledDate;
  final String location;
  final String locationDetails;
  final int quantity;
  final Map<String, double>? providerLocation;
  final String status;
  final double totalAmount;
  final double? discountAmount;
  final String? offerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ServiceProvider? provider;
  final ServiceSubcategory? service;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.scheduledDate,
    required this.location,
    required this.locationDetails,
    required this.quantity,
    this.providerLocation,
    required this.status,
    required this.totalAmount,
    this.discountAmount,
    this.offerId,
    required this.createdAt,
    this.updatedAt,
    this.provider,
    this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      scheduledDate: DateTime.parse(
          json['scheduledDate'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      locationDetails: json['locationDetails'] ?? '',
      quantity: json['quantity'] ?? 1,
      providerLocation: json['providerLocation'] != null
          ? Map<String, double>.from(json['providerLocation'])
          : null,
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      offerId: json['offerId']?.toString(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      provider: json['provider'] != null
          ? ServiceProvider.fromJson(json['provider'])
          : null,
      service: json['service'] != null
          ? ServiceSubcategory.fromJson(json['service'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'location': location,
      'locationDetails': locationDetails,
      'quantity': quantity,
      'providerLocation': providerLocation,
      'status': status,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'offerId': offerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'provider': provider?.toJson(),
      'service': service?.toJson(),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? serviceId,
    DateTime? scheduledDate,
    String? location,
    String? locationDetails,
    int? quantity,
    Map<String, double>? providerLocation,
    String? status,
    double? totalAmount,
    double? discountAmount,
    String? offerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ServiceProvider? provider,
    ServiceSubcategory? service,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      quantity: quantity ?? this.quantity,
      providerLocation: providerLocation ?? this.providerLocation,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      offerId: offerId ?? this.offerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      provider: provider ?? this.provider,
      service: service ?? this.service,
    );
  }
}

// Order Model (API equivalent of Booking)
class Order {
  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final DateTime scheduledDate;
  final String location;
  final String locationDetails;
  final int quantity;
  final Map<String, double>? providerLocation;
  final String status;
  final double totalAmount;
  final double? discountAmount;
  final String? offerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ServiceProvider? provider;
  final ServiceSubcategory? service;

  Order({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.scheduledDate,
    required this.location,
    required this.locationDetails,
    required this.quantity,
    this.providerLocation,
    required this.status,
    required this.totalAmount,
    this.discountAmount,
    this.offerId,
    required this.createdAt,
    this.updatedAt,
    this.provider,
    this.service,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      scheduledDate: DateTime.parse(
          json['scheduledDate'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      locationDetails: json['locationDetails'] ?? '',
      quantity: json['quantity'] ?? 1,
      providerLocation: json['providerLocation'] != null
          ? Map<String, double>.from(json['providerLocation'])
          : null,
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      offerId: json['offerId']?.toString(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      provider: json['provider'] != null
          ? ServiceProvider.fromJson(json['provider'])
          : null,
      service: json['service'] != null
          ? ServiceSubcategory.fromJson(json['service'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'location': location,
      'locationDetails': locationDetails,
      'quantity': quantity,
      'providerLocation': providerLocation,
      'status': status,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'offerId': offerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'provider': provider?.toJson(),
      'service': service?.toJson(),
    };
  }

  // Convert Order to Booking for backward compatibility
  Booking toBooking() {
    return Booking(
      id: id,
      userId: userId,
      providerId: providerId,
      serviceId: serviceId,
      scheduledDate: scheduledDate,
      location: location,
      locationDetails: locationDetails,
      quantity: quantity,
      providerLocation: providerLocation,
      status: status,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      offerId: offerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      provider: provider,
      service: service,
    );
  }
}

// Invoice Model
class Invoice {
  final String id;
  final String orderId;
  final String userId;
  final String providerId;
  final double amount;
  final String status;
  final String? paymentMethod;
  final DateTime dueDate;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Order? order;

  Invoice({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.providerId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    required this.dueDate,
    this.paidAt,
    required this.createdAt,
    this.updatedAt,
    this.order,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      dueDate:
          DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'providerId': providerId,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'dueDate': dueDate.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'order': order?.toJson(),
    };
  }
}

// Create Order Request Model
class CreateOrderRequest {
  final String providerId;
  final String serviceId;
  final DateTime scheduledDate;
  final String location;
  final String locationDetails;
  final int quantity;
  final Map<String, double>? providerLocation;

  CreateOrderRequest({
    required this.providerId,
    required this.serviceId,
    required this.scheduledDate,
    required this.location,
    required this.locationDetails,
    required this.quantity,
    this.providerLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'serviceId': serviceId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'location': location,
      'locationDetails': locationDetails,
      'quantity': quantity,
      'providerLocation': providerLocation,
    };
  }
}
