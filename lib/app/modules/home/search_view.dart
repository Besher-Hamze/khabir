import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../global_widgets/custom_appbar.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode searchFocusNode = FocusNode();

  // Sample data for search suggestions
  List<String> cities = [
    'Muscat',
    'Salalah',
    'Nizwa',
    'Sur',
    'Sohar',
    'Rustaq',
    'Bahla',
    'Ibri',
    'Samail',
    'Buraimi',
  ];

  List<String> services = [
    'Electrical Services',
    'Plumbing',
    'Air Conditioning',
    'Cleaning Services',
    'Painting',
    'Carpentry',
    'Gardening',
    'Home Repairs',
    'Appliance Repair',
    'Pest Control',
  ];

  List<String> filteredCities = [];
  List<String> filteredServices = [];
  bool showCitySuggestions = false;
  bool showServiceSuggestions = false;

  @override
  void initState() {
    super.initState();

    cityController.addListener(() {
      _filterCities();
    });

    searchController.addListener(() {
      _filterServices();
    });

    cityFocusNode.addListener(() {
      setState(() {
        showCitySuggestions =
            cityFocusNode.hasFocus && cityController.text.isNotEmpty;
      });
    });

    searchFocusNode.addListener(() {
      setState(() {
        showServiceSuggestions =
            searchFocusNode.hasFocus && searchController.text.isNotEmpty;
      });
    });
  }

  void _filterCities() {
    setState(() {
      if (cityController.text.isEmpty) {
        filteredCities = [];
        showCitySuggestions = false;
      } else {
        filteredCities = cities
            .where((city) =>
                city.toLowerCase().contains(cityController.text.toLowerCase()))
            .toList();
        showCitySuggestions = cityFocusNode.hasFocus;
      }
    });
  }

  void _filterServices() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredServices = [];
        showServiceSuggestions = false;
      } else {
        filteredServices = services
            .where((service) => service
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
        showServiceSuggestions = searchFocusNode.hasFocus;
      }
    });
  }

  @override
  void dispose() {
    cityController.dispose();
    searchController.dispose();
    cityFocusNode.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const DetailAppBar(
        title: 'Search',
        notificationCount: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // Hide suggestions when tapping outside
          FocusScope.of(context).unfocus();
          setState(() {
            showCitySuggestions = false;
            showServiceSuggestions = false;
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Search a City Field
              _buildSearchField(
                controller: cityController,
                focusNode: cityFocusNode,
                hintText: 'Search a City',
                icon: LucideIcons.mapPin,
                showSuggestions: showCitySuggestions,
                suggestions: filteredCities,
                onSuggestionTap: (city) {
                  cityController.text = city;
                  setState(() {
                    showCitySuggestions = false;
                  });
                  FocusScope.of(context).unfocus();
                  _searchInCity(city);
                },
              ),

              const SizedBox(height: 20),

              // General Search Field
              _buildSearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: 'Search',
                icon: LucideIcons.search,
                showSuggestions: showServiceSuggestions,
                suggestions: filteredServices,
                onSuggestionTap: (service) {
                  searchController.text = service;
                  setState(() {
                    showServiceSuggestions = false;
                  });
                  FocusScope.of(context).unfocus();
                  _searchForService(service);
                },
              ),

              const SizedBox(height: 40),

              // Popular Searches Section
              if (!showCitySuggestions && !showServiceSuggestions) ...[
                // Recent Searches Section
                _buildRecentSearches(),
              ],
            ],
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
            prefixIcon: Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
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
              if (hintText == 'Search a City') {
                _searchInCity(value);
              } else {
                _searchForService(value);
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
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
        const Text(
          'Popular Searches',
          style: TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        const Text(
          'Recent Searches',
          style: TextStyle(
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
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
      'City Search',
      'Searching for services in $city',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    // Implement your city search logic here
  }

  void _searchForService(String service) {
    print('Searching for service: $service');
    Get.snackbar(
      'Service Search',
      'Searching for $service',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    // Implement your service search logic here
  }
}
