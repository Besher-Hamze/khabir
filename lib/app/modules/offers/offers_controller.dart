import 'package:get/get.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/offers_repository.dart';

class OffersController extends GetxController {
  final OffersRepository _offersRepository;

  OffersController(this._offersRepository);

  // Observables
  final RxList<OfferModel> offers = <OfferModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOffers();
  }

  /// Load all available offers
  Future<void> loadOffers() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final List<OfferModel> loadedOffers = await _offersRepository
          .getAvailableOffers();
      offers.value = loadedOffers;

      print('Successfully loaded ${offers.length} offers');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading offers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh offers
  Future<void> refreshOffers() async {
    await loadOffers();
  }

  /// Get active offers only
  List<OfferModel> get activeOffers =>
      offers.where((offer) => offer.isActive).toList();

  /// Get offers count
  int get offersCount => offers.length;

  /// Get active offers count
  int get activeOffersCount => activeOffers.length;

  /// Check if offers are available
  bool get hasOffers => offers.isNotEmpty;

  /// Check if active offers are available
  bool get hasActiveOffers => activeOffers.isNotEmpty;

  /// Format date for display
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Calculate discount percentage
  double calculateDiscountPercentage(double originalPrice, double offerPrice) {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - offerPrice) / originalPrice * 100).roundToDouble();
  }

  /// Check if offer is expiring soon (within 7 days)
  bool isExpiringSoon(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference <= 7 && difference >= 0;
  }

  /// Check if offer has expired
  bool isExpired(DateTime endDate) {
    return DateTime.now().isAfter(endDate);
  }
}
