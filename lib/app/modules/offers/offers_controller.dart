import 'package:get/get.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/services_repository.dart';
import '../../routes/app_routes.dart';

class OffersController extends GetxController {
  final ServicesRepository _servicesRepository = Get.find<ServicesRepository>();

  var isLoading = false.obs;
  var offers = <Offer>[].obs;
  var selectedCategory = 'all'.obs;

  final categories = [
    'all',
    'electricity',
    'plumbing',
    'cleaning',
    'air_conditioning',
    'painting',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOffers();
  }

  Future<void> loadOffers() async {
    isLoading.value = true;
    try {
      final offersList = await _servicesRepository.getActiveOffers();
      offers.value = offersList;
    } catch (e) {
      print('Error loading offers: $e');
      // Fallback to mock data
      offers.value = _getMockOffers();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    // In real app, filter offers by category
  }

  void goToOffer(Offer offer) {
    Get.toNamed(AppRoutes.providerDetails, arguments: {'offer': offer});
  }

  void bookOffer(Offer offer) {
    Get.toNamed(AppRoutes.bookService, arguments: {'offer': offer});
  }

  List<Offer> get filteredOffers {
    if (selectedCategory.value == 'all') {
      return offers.where((offer) => offer.isActiveNow).toList();
    }
    return offers
        .where(
          (offer) =>
              offer.service?.nameEn.toLowerCase().contains(
                    selectedCategory.value,
                  ) ==
                  true &&
              offer.isActiveNow,
        )
        .toList();
  }

  List<Offer> _getMockOffers() {
    final mockProviders = [
      ServiceProvider(
        id: '1',
        name: 'أحمد محمد',
        phone: '+966501234567',
        state: 'الرياض',
        city: 'الرياض',
        rating: 4.8,
        reviewsCount: 25,
        status: ProviderStatus.online,
        isVerified: true,
        isFeatured: true,
        description: 'كهربائي محترف مع خبرة 10 سنوات',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      ServiceProvider(
        id: '2',
        name: 'فاطمة أحمد',
        phone: '+966503456789',
        state: 'الرياض',
        city: 'الرياض',
        rating: 4.9,
        reviewsCount: 42,
        status: ProviderStatus.online,
        isVerified: true,
        isFeatured: true,
        description: 'متخصصة في التنظيف العميق للمنازل',
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      ServiceProvider(
        id: '3',
        name: 'خالد النجار',
        phone: '+966505678901',
        state: 'الرياض',
        city: 'الرياض',
        rating: 4.7,
        reviewsCount: 35,
        status: ProviderStatus.online,
        isVerified: true,
        isFeatured: true,
        description: 'دهان محترف للمنازل والمكاتب',
        createdAt: DateTime.now().subtract(const Duration(days: 450)),
      ),
    ];

    final mockServices = [
      ServiceSubcategory(
        id: '1',
        categoryId: '1',
        nameAr: 'خدمات كهربائية',
        nameEn: 'Electrical Services',
        basePrice: 200.0,
      ),
      ServiceSubcategory(
        id: '2',
        categoryId: '2',
        nameAr: 'تنظيف عميق',
        nameEn: 'Deep Cleaning',
        basePrice: 300.0,
      ),
      ServiceSubcategory(
        id: '3',
        categoryId: '3',
        nameAr: 'أعمال دهان',
        nameEn: 'Painting Services',
        basePrice: 800.0,
      ),
    ];

    return [
      Offer(
        id: '1',
        providerId: '1',
        serviceId: '1',
        title: 'خصم 30% على خدمات الكهرباء',
        description: 'تركيب وصيانة جميع الأعمال الكهربائية',
        originalPrice: 200.0,
        offerPrice: 140.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        isActive: true,
        createdAt: DateTime.now(),
        service: mockServices[0],
      ),
      Offer(
        id: '2',
        providerId: '2',
        serviceId: '2',
        title: 'عرض خاص على التنظيف العميق',
        description: 'تنظيف شامل للمنزل مع التعقيم',
        originalPrice: 300.0,
        offerPrice: 210.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 3)),
        isActive: true,
        createdAt: DateTime.now(),
        service: mockServices[1],
      ),
      Offer(
        id: '3',
        providerId: '3',
        serviceId: '3',
        title: 'خصم 25% على أعمال الدهان',
        description: 'دهان الجدران الداخلية والخارجية',
        originalPrice: 800.0,
        offerPrice: 600.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 12)),
        isActive: true,
        createdAt: DateTime.now(),
        service: mockServices[2],
      ),
      Offer(
        id: '4',
        providerId: '2',
        serviceId: '2',
        title: 'تنظيف المكاتب بأسعار مخفضة',
        description: 'خدمة تنظيف احترافية للمكاتب والشركات',
        originalPrice: 150.0,
        offerPrice: 120.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        isActive: true,
        createdAt: DateTime.now(),
        service: mockServices[1],
      ),
      Offer(
        id: '5',
        providerId: '1',
        serviceId: '1',
        title: 'صيانة كهربائية شاملة',
        description: 'فحص وصيانة التمديدات الكهربائية',
        originalPrice: 250.0,
        offerPrice: 175.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 2)),
        isActive: true,
        createdAt: DateTime.now(),
        service: mockServices[0],
      ),
    ];
  }

  Future<void> refreshOffers() async {
    await loadOffers();
  }
}
