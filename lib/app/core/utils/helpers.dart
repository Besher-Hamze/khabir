import 'package:khabir/app/core/constants/app_constants.dart';

String getImageUrl(String image) {
  if (image.contains('http')) {
    return image;
  }
  return '${AppConstants.baseUrlImage}$image';
}

// make it just date not time
String formatDate(String date) {
  return '${DateTime.parse(date).day.toString().padLeft(2, '0')}/${DateTime.parse(date).month.toString().padLeft(2, '0')}/${DateTime.parse(date).year}';
}
