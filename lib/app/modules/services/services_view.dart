import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import '../../core/utils/app_translations.dart';
import 'services_controller.dart';
import '../../data/models/service_model.dart';
import '../service providers/service_providers_view.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ServicesController controller = Get.find<ServicesController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.categoryName.isNotEmpty
                  ? controller.categoryName
                  : 'services'.tr,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [],
      ),
      body: Obx(() {
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
                  onPressed: controller.refreshServices,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        if (!controller.hasServices) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.build_outlined, size: 64, color: Colors.grey[400]),
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
                  'no_services_available'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshServices,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              return _buildServiceItem(controller.services[index], controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildServiceItem(
    ServiceModel service,
    ServicesController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.onServiceSelected(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  service.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 24, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
