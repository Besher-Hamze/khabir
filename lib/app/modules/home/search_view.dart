import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:khabir/app/routes/app_routes.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../global_widgets/custom_appbar.dart';
import '../../data/models/provider_model.dart';
import '../../core/utils/helpers.dart';
import '../../core/values/colors.dart';
import 'search_controller.dart' as search;

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode searchFocusNode = FocusNode();

  late final search.SearchController searchControllerGetx;

  List<String> filteredCities = [];
  List<String> filteredServices = [];

  @override
  void initState() {
    super.initState();

    searchControllerGetx = Get.put(search.SearchController());
  }

  @override
  void dispose() {
    cityController.dispose();
    searchTextController.dispose();
    cityFocusNode.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: DetailAppBar(title: 'search'.tr, notificationCount: 0.obs),
      body: GestureDetector(
        onTap: () {
          // Hide suggestions when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: RefreshIndicator(
          onRefresh: searchControllerGetx.refresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search a City Field
                _buildSearchField(
                  controller: cityController,
                  focusNode: cityFocusNode,
                  hintText: 'search_a_city'.tr,
                  icon: LucideIcons.mapPin,
                  showSuggestions: false,
                  suggestions: filteredCities,
                  onSuggestionTap: (city) {
                    cityController.text = city;

                    FocusScope.of(context).unfocus();
                    searchControllerGetx.filterByCity(city);
                  },
                ),

                const SizedBox(height: 20),

                // General Search Field
                _buildSearchField(
                  controller: searchTextController,
                  focusNode: searchFocusNode,
                  hintText: 'search'.tr,
                  icon: LucideIcons.search,
                  showSuggestions: false,
                  suggestions: filteredServices,
                  onSuggestionTap: (service) {
                    searchTextController.text = service;

                    FocusScope.of(context).unfocus();
                    searchControllerGetx.searchProviders(service);
                  },
                ),

                const SizedBox(height: 40),

                // Providers List Section
                _buildProvidersList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required bool showSuggestions,
    required List<String> suggestions,
    required Function(String) onSuggestionTap,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              if (hintText == 'search_a_city'.tr) {
                searchControllerGetx.filterByCity(value);
              } else {
                searchControllerGetx.searchProviders(value);
              }
            }
          },
        ),

        // Suggestions Dropdown
        if (showSuggestions && suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length > 5 ? 5 : suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  leading: Icon(
                    LucideIcons.search,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  title: Text(
                    suggestions[index],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  trailing: const Icon(
                    LucideIcons.arrowUpLeft,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () => onSuggestionTap(suggestions[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPopularSearches() {
    List<String> popularSearches = [
      'Electrical Repair',
      'AC Installation',
      'House Cleaning',
      'Plumbing Services',
      'Painting Work',
      'Gardening',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'popular_searches'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: popularSearches.map((search) {
            return GestureDetector(
              onTap: () => _searchForService(search),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.trendingUp,
                      size: 14,
                      color: Colors.red[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      search,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    List<String> recentSearches = [
      'Electrical Services in Muscat',
      'AC Repair',
      'House Cleaning Salalah',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_searches'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...recentSearches.map((search) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              leading: Icon(
                LucideIcons.clock,
                size: 18,
                color: Colors.grey[600],
              ),
              title: Text(
                search,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              trailing: Icon(
                LucideIcons.arrowUpLeft,
                size: 16,
                color: Colors.grey[600],
              ),
              onTap: () => _searchForService(search),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _searchInCity(String city) {
    print('Searching in city: $city');
    Get.snackbar(
      'provider_search'.tr,
      'searching_in_city'.tr + ' $city',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    // Implement your city search logic here
  }

  void _searchForService(String service) {
    print('Searching for service: $service');
    Get.snackbar(
      'service_search'.tr,
      'searching_for_service'.tr + ' $service',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    // Implement your service search logic here
  }

  Widget _buildProvidersList() {
    return Obx(() {
      if (searchControllerGetx.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (searchControllerGetx.hasError.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'error'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: searchControllerGetx.refresh,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          ),
        );
      }

      if (searchControllerGetx.filteredProviders.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'no_providers_found'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'no_providers_message'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'all_providers'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (searchControllerGetx.searchQuery.value.isNotEmpty ||
                  searchControllerGetx.selectedCity.value.isNotEmpty)
                TextButton(
                  onPressed: searchControllerGetx.clearFilters,
                  child: Text('clear'.tr),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...searchControllerGetx.filteredProviders
              .map((provider) => _buildProviderCard(provider))
              .toList(),
        ],
      );
    });
  }

  Widget _buildProviderCard(Provider provider) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.requestService,
        arguments: {'provider': provider},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Provider Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: provider.image.isNotEmpty
                      ? NetworkImage(getImageUrl(provider.image))
                      : const AssetImage('assets/images/logo-04.png')
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Provider Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.state,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (provider.city != null) ...[
                        Text(
                          ', ${provider.city}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.averageRating.toStringAsFixed(1)} (${provider.totalRatings})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Verification Badge
            if (provider.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'verified'.tr,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
