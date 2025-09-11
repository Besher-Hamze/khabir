import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import 'categories_controller.dart';
import '../../data/models/category_model.dart';

class CategoriesView extends StatelessWidget {
  final bool showAppBar;
  final bool showFilter;

  const CategoriesView({
    Key? key,
    this.showAppBar = true,
    this.showFilter = true,
  }) : super(key: key);

  // Factory constructor for navigation bar use (minimal version)
  factory CategoriesView.minimal({Key? key}) {
    return CategoriesView(key: key, showAppBar: false, showFilter: false);
  }

  // Factory constructor for navigation bar use with filter
  factory CategoriesView.navBar({Key? key, bool showFilter = false}) {
    return CategoriesView(key: key, showAppBar: false, showFilter: showFilter);
  }

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.find<CategoriesController>();

    Widget content = Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
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
                onPressed: controller.refreshCategories,
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      if (controller.categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'no_data'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'no_categories_available'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshCategories,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount:
                controller.categories.length +
                1, // +1 for static Khabir Category
            itemBuilder: (context, index) {
              // Show static Khabir Category first
              if (index == 0) {
                return _buildKhabirCategoryItem(controller);
              }
              // Show regular categories (adjust index by -1)
              return _buildCategoryItem(
                controller.categories[index - 1],
                controller,
              );
            },
          ),
        ),
      );
    });

    // If showAppBar is false, return just the content (for navigation bar)
    if (!showAppBar) {
      return content;
    }

    // If showAppBar is true, return with Scaffold and AppBar (for standalone page)
    return Scaffold(
      appBar: AppBar(
        title: Text('categories'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: content,
    );
  }

  Widget _buildKhabirCategoryItem(CategoriesController controller) {
    return GestureDetector(
      onTap: () => controller.onKhabirCategorySelected(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Khabir Category Image/Icon Container
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: Icon(Icons.star, size: 35, color: AppColors.primary),
                ),
              ),
            ),

            // Khabir Category Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'khabir_category'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    CategoryModel category,
    CategoriesController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.onCategorySelected(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Category Image/Icon Container
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: controller.categoryHasImage(category)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            controller.getCategoryImageUrl(category),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.work,
                                size: 35,
                                color: AppColors.primary,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        )
                      : Image.asset(
                          controller.getDefaultIcon(),
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.work,
                              size: 35,
                              color: AppColors.primary,
                            );
                          },
                        ),
                ),
              ),
            ),

            // Category Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                controller.getCategoryTitle(category),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
