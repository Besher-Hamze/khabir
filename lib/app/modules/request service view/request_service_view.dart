import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/core/utils/helpers.dart';
import '../../core/values/colors.dart';
import 'request_service_controller.dart';
import '../../data/models/provider_model.dart';
import '../../widgets/map_picker_widget.dart';
import '../../data/models/user_location_model.dart';

class RequestServiceView extends StatelessWidget {
  const RequestServiceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RequestServiceController controller =
        Get.find<RequestServiceController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'request_for_service'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/images/logo-02.png',
              height: 35,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 35,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'khabir',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
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

          if (controller.services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'no_services_available'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'provider_no_services_message'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshServices,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Info Card
                  _buildProviderInfoCard(controller),
                  const SizedBox(height: 24),

                  // Services List
                  _buildServicesList(controller),
                  const SizedBox(height: 24),

                  // Duration and Location Section
                  _buildDurationLocationSection(controller),
                  const SizedBox(height: 16),

                  // Total Price Section - Make it reactive
                  Obx(() => _buildTotalPriceSection(controller)),
                  const SizedBox(height: 24),

                  // Notes Section
                  _buildNotesSection(controller),
                  const SizedBox(height: 24),

                  // Submit Button - Make it reactive
                  Obx(() => _buildSubmitButton(controller)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProviderInfoCard(RequestServiceController controller) {
    final provider = controller.provider;
    if (provider == null) return const SizedBox.shrink();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row - Image, Name, Rating
          Row(
            children: [
              // Circular Provider Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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

              // Provider Name and Service Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.services
                          .where(
                            (service) => service.id == controller.serviceId,
                          )
                          .first
                          .title, // Use actu al service type from provider model
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.rate.toString(), // Use actual rating
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Description Section
          Text(
            'Description',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Description Text
          Text(
            provider.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(RequestServiceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'available_services'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.services
            .map((service) => _buildServiceItem(service, controller))
            .toList(),
      ],
    );
  }

  Widget _buildServiceItem(
    ProviderServiceItem service,
    RequestServiceController controller,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Header
          Row(
            children: [
              // Service Details
              Text(
                service.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'price'.tr +
                          ': ${service.offerPrice != null ? service.offerPrice : service.price} OMR',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Controls - Wrap in Obx for reactivity
              Obx(() {
                final quantity = controller.getServiceQuantity(service.id);

                return Row(
                  children: [
                    // Minus Button
                    GestureDetector(
                      onTap: () {
                        if (quantity > 0) {
                          controller.updateServiceQuantity(
                            service.id,
                            quantity - 1,
                          );
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: quantity > 0
                              ? AppColors.primary
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: quantity > 0 ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),

                    // Quantity Display
                    Container(
                      width: 40,
                      child: Center(
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Plus Button
                    GestureDetector(
                      onTap: () {
                        controller.updateServiceQuantity(
                          service.id,
                          quantity + 1,
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          // Total Price for this service - Wrap in Obx for reactivity
          Obx(() {
            final quantity = controller.getServiceQuantity(service.id);
            final isSelected = quantity > 0;

            if (!isSelected) return const SizedBox.shrink();

            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'total_for_this_service'.tr + ':',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${controller.getServiceTotalPrice(service.id).toStringAsFixed(2)} OMR',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDurationLocationSection(RequestServiceController controller) {
    return Container(
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
      child: Column(
        children: [
          // Duration Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'duration'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(
                () => Row(
                  children: [
                    Expanded(child: _buildDurationButton('Now', controller)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDurationButton('Tomorrow', controller),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildCalendarButton(controller)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 24),

          // Location Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'location'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Location Display and Selection
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.selectedLocation.value?.address ??
                                  'no_location_selected'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _showLocationPickerDialog(controller),
                            icon: const Icon(
                              Icons.edit_location,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (controller.selectedLocation.value != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${controller.selectedLocation.value!.title} - ${controller.selectedLocation.value!.description}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationButton(
    String text,
    RequestServiceController controller,
  ) {
    final isSelected = controller.selectedDuration.value == text;
    return GestureDetector(
      onTap: () => controller.setDuration(text),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            (text.toLowerCase()).tr,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarButton(RequestServiceController controller) {
    final isSelected =
        controller.selectedDuration.value == 'Calendar' ||
        controller.selectedDate.value != null;
    String displayText = controller.selectedDate.value != null
        ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
        : 'calendar'.tr;

    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: controller.selectedDate.value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          controller.setDate(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: controller.selectedDate.value != null ? 11 : 13,
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPriceSection(RequestServiceController controller) {
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'selected_services'.tr +
                    ': ${controller.selectedServicesCount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                'total_amount'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'duration'.tr}: ${controller.selectedDuration.value.toLowerCase().tr}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                '${controller.getTotalPrice().toStringAsFixed(2)} OMR',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (controller.selectedDate.value != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${'date'.tr}: ${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(RequestServiceController controller) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.note, size: 18, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Text(
                'additional_notes'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => controller.notes.value = value,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'add_any_special_instructions_or_notes_for_the_provider'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(RequestServiceController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            (controller.hasSelectedServices && !controller.isSubmitting.value)
            ? () => _showConfirmationDialog(controller)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: controller.isSubmitting.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Submitting...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                'Submit Request (${controller.selectedServicesCount} services)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // Add this method to your RequestServiceView class
  void _showConfirmationDialog(RequestServiceController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'confirm_request'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                'are_you_sure_you_want_to_submit_this_service_request?'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.black54,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Confirm Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.submitRequest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'confirm'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );
  }

  void _showLocationPickerDialog(RequestServiceController controller) {
    double? selectedLatitude;
    double? selectedLongitude;
    String selectedAddress = '';

    Get.dialog(
      AlertDialog(
        title: Text('select_service_location'.tr),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),

                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'tap_map_select_location'.tr,
                        style: TextStyle(color: Colors.blue[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Map Picker
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: MapPickerWidget(
                      initialLatitude:
                          controller.selectedLocation.value?.latitude,
                      initialLongitude:
                          controller.selectedLocation.value?.longitude,
                      initialAddress:
                          controller.selectedLocation.value?.address,
                      onLocationSelected: (latitude, longitude, address) {
                        selectedLatitude = latitude;
                        selectedLongitude = longitude;
                        selectedAddress = address;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              if (selectedLatitude != null && selectedLongitude != null) {
                // Create a temporary location model for the selected coordinates
                final tempLocation = UserLocationModel(
                  id: -1, // Temporary ID
                  title: 'Selected Location',
                  description: 'Temporarily selected for this service',
                  latitude: selectedLatitude!,
                  longitude: selectedLongitude!,
                  address: selectedAddress.isNotEmpty
                      ? selectedAddress
                      : 'Selected Location',
                  isDefault: false,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                controller.setLocation(tempLocation);
                Get.back();
              } else {
                Get.snackbar(
                  'error'.tr,
                  'please_select_location'.tr,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('confirm_location'.tr),
          ),
        ],
      ),
    );
  }
}
