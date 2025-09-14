import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/offer_model.dart';
import 'package:khabir/app/data/repositories/providers_repository.dart';
import 'package:khabir/app/routes/app_routes.dart';
import '../../core/values/colors.dart';
import '../../data/models/provider_model.dart';
import '../../core/utils/helpers.dart' as Helpers;
import 'offers_controller.dart';

class OffersView extends GetView<OffersController> {
  const OffersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return _buildErrorWidget();
        }

        if (!controller.hasOffers) {
          return _buildEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOffers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.offers.length,
            itemBuilder: (context, index) {
              final offer = controller.offers[index];
              return _buildOfferCard(offer);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOfferCard(OfferModel offer) {
    final discountPercentage = controller.calculateDiscountPercentage(
      offer.originalPrice,
      offer.offerPrice,
    );
    final isExpiringSoon = controller.isExpiringSoon(offer.endDate);
    final isExpired = controller.isExpired(offer.endDate);

    return GestureDetector(
      onTap: () => _onOfferTap(offer),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Offer Image and Badge
            Stack(
              children: [
                // Service Image
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: offer.service.image.isNotEmpty
                          ? NetworkImage(
                              Helpers.getImageUrl(offer.service.image),
                            )
                          : const AssetImage('assets/images/logo-04.png')
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Discount Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${discountPercentage.toInt()}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Expiring Soon Badge
                if (isExpiringSoon && !isExpired)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EXPIRING SOON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Expired Badge
                if (isExpired)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EXPIRED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Offer Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title
                  Text(
                    offer.service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Service Description
                  if (offer.service.description.isNotEmpty)
                    Text(
                      offer.service.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Provider Info
                  Row(
                    children: [
                      // Provider Image
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: offer.provider.image.isNotEmpty
                                ? NetworkImage(
                                    Helpers.getImageUrl(offer.provider.image),
                                  )
                                : const AssetImage('assets/images/logo-04.png')
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Provider Name and Verification
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              offer.provider.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (offer.provider.isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.green,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price Section
                  Row(
                    children: [
                      // Offer Price
                      Text(
                        '${offer.offerPrice} OMR',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Original Price (Strikethrough)
                      Text(
                        '${offer.originalPrice} OMR',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                      const Spacer(),

                      // Savings
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Save ${(offer.originalPrice - offer.offerPrice).toStringAsFixed(1)} OMR',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Offer Description
                  if (offer.description.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              offer.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[700],
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Validity Period
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Valid until: ${controller.formatDate(offer.endDate)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'failed_to_load_offers'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.loadOffers,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text('try_again'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'no_offers_available'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'check_back_later_offers'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.refreshOffers,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text('refresh'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onOfferTap(OfferModel offer) async {
    // Navigate to service request or provider detail
    Provider prvoider = await Get.find<ProvidersRepository>().getProviderById(
      offer.providerId.toString(),
    );

    // Find the matching service safely
    final matchingServices = prvoider.services.where(
      (s) => s.id == offer.serviceId,
    );
    if (matchingServices.isEmpty) {
      return;
    }

    final service = matchingServices.first;

    Get.toNamed(
      AppRoutes.requestService,
      arguments: {
        'provider': prvoider,
        'serviceId': offer.serviceId,
        'serviceName': offer.service.title,
        'categoryName': service.category?.titleEn,
        'categoryState': service.category?.state,
        'categoryId': service.categoryId,
      },
    );
  }
}
