import 'package:get/get.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/providers_repository.dart';

class SearchController extends GetxController {
  final ProvidersRepository _providersRepository =
      Get.find<ProvidersRepository>();

  final RxList<Provider> allProviders = <Provider>[].obs;
  final RxList<Provider> filteredProviders = <Provider>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedCity = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllProviders();
  }

  Future<void> fetchAllProviders() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final providers = await _providersRepository.getAllProviders();
      allProviders.value = providers;
      filteredProviders.value = providers;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void searchProviders(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredProviders.value = allProviders;
      return;
    }

    final filtered = allProviders.where((provider) {
      final nameMatch = provider.name.toLowerCase().contains(
        query.toLowerCase(),
      );
      final descriptionMatch = provider.description.toLowerCase().contains(
        query.toLowerCase(),
      );
      final stateMatch = provider.state.toLowerCase().contains(
        query.toLowerCase(),
      );

      return nameMatch || descriptionMatch || stateMatch;
    }).toList();

    filteredProviders.value = filtered;
  }

  void filterByCity(String city) {
    selectedCity.value = city;

    if (city.isEmpty) {
      filteredProviders.value = allProviders;
      return;
    }

    final filtered = allProviders.where((provider) {
      return provider.state.toLowerCase().contains(city.toLowerCase());
    }).toList();

    filteredProviders.value = filtered;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCity.value = '';
    filteredProviders.value = allProviders;
  }

  Future<void> refresh() async {
    await fetchAllProviders();
  }
}
