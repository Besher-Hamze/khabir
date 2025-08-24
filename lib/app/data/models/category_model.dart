class CategoryModel {
  final int id;
  final String image;
  final String titleAr;
  final String titleEn;
  final String state;

  CategoryModel({
    required this.id,
    required this.image,
    required this.titleAr,
    required this.titleEn,
    required this.state,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'state': state,
    };
  }

  // Get title based on current language
  String getTitle(String language) {
    return language == 'ar' ? titleAr : titleEn;
  }

  // Check if category has an image
  bool get hasImage => image.isNotEmpty;

  // Get image URL with base URL
  String getImageUrl() {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return 'http://31.97.71.187:3000$image';
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
