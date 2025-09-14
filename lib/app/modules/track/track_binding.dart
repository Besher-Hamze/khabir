import 'package:get/get.dart';
import 'package:khabir/app/data/repositories/location_tracking_repository.dart';
import 'package:khabir/app/modules/track/track_controller.dart';

class LocationTrackingBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocationTrackingRepository as PERMANENT singleton
    Get.put<LocationTrackingRepository>(
      LocationTrackingRepository(),
      permanent: true,
    );

    // Register LocationTrackingController as PERMANENT singleton
    Get.put<LocationTrackingController>(
      LocationTrackingController(),
      permanent: true,
    );

    print('🔗 BINDING: Repository and Controller registered as singletons');
  }
}
