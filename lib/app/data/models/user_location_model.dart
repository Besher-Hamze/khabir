class UserLocationResponse {
  final List<UserLocationModel> locations;

  UserLocationResponse({required this.locations});

  factory UserLocationResponse.fromJson(List json) {
    return UserLocationResponse(
      locations: json?.map((e) => UserLocationModel.fromJson(e)).toList() ?? [],
    );
  }
}

class UserLocationModel {
  final int id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserLocationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      isDefault: json['isDefault'] ?? false,
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
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateLocationRequest {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final bool isDefault;

  CreateLocationRequest({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isDefault': isDefault,
    };
  }
}

class UpdateLocationRequest {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String address;

  UpdateLocationRequest({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

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
