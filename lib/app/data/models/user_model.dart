class User {
  final String id;
  final String name;
  final String phoneNumber;
  // final String? email;
  final String? profileImage;
  final String? address;
  final String? state;
  final String role;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    // this.email,
    this.profileImage,
    this.address,
    this.state,
    required this.role,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      // email: json['email'],
      profileImage: json['profileImage'],
      address: json['address'],
      state: json['state'],
      role: json['role'] ?? 'USER',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      // 'email': email,
      'profileImage': profileImage,
      'address': address,
      'state': state,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    // String? email,
    String? profileImage,
    String? address,
    String? state,
    String? role,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      //  email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      state: state ?? this.state,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// API Response Models
class AuthResponse {
  final bool success;
  final String message;
  final String? accessToken;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.accessToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? json['accessToken'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? total;
  final int? page;
  final int? limit;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.total,
    this.page,
    this.limit,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}
