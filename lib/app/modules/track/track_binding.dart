import 'package:get/get.dart';
import 'package:khabir/app/data/repositories/location_tracking_repository.dart';
import 'package:khabir/app/modules/track/track_controller.dart';

class LocationTrackingBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocationTrackingRepository
    Get.lazyPut<LocationTrackingRepository>(() => LocationTrackingRepository());

    // Register LocationTrackingController
    Get.lazyPut<LocationTrackingController>(() => LocationTrackingController());
  }
}
