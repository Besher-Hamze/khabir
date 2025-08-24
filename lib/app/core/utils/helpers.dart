import 'package:khabir/app/core/constants/app_constants.dart';

String getImageUrl(String image) {
  if (image.contains('http')) {
    return image;
  }
  return '${AppConstants.baseUrlImage}$image';
}
