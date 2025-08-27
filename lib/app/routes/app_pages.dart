import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/modules/notifications/notifications_view.dart';
import 'package:khabir/app/modules/services/services_view.dart';
import 'package:khabir/app/modules/user/user_binding.dart';
import '../modules/home/search_view.dart';
import 'app_routes.dart';

// Import actual modules
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/role_selection/role_selection_binding.dart';
import '../modules/role_selection/role_selection_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/signup_view.dart';
import '../modules/auth/forgot_password_view.dart';
import '../modules/auth/verify_phone_view.dart';
import '../modules/auth/reset_password_view.dart';
import '../modules/main/main_binding.dart';
import '../modules/main/main_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/bookings/my_bookings_view.dart';
import '../modules/bookings/my_bookings_binding.dart';
import '../modules/categories/categories_view.dart';
import '../modules/categories/categories_binding.dart';
import '../modules/services/services_view.dart';
import '../modules/services/services_binding.dart';
import '../modules/offers/offers_binding.dart';
import '../modules/offers/offers_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/notifications/notifications_binding.dart';
import '../modules/service providers/service_providers_view.dart';
import '../modules/service providers/service_providers_binding.dart';
import '../modules/request service view/request_service_view.dart';
import '../modules/request service view/request_service_binding.dart';
import '../modules/success page/success_page_view.dart';
import '../modules/success page/success_page_binding.dart';
import '../modules/orders/orders_view.dart';
import '../modules/orders/orders_binding.dart';
import '../modules/provider detail/provider_detail_view.dart';
import '../modules/provider detail/provider_detail_binding.dart';
import '../modules/all providers/all_providers_view.dart';
import '../modules/all providers/all_providers_binding.dart';
import '../modules/offers/offers_view.dart';
import '../modules/offers/offers_binding.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Onboarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),

    // Role Selection
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),

    // Auth Routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.verifyPhone,
      page: () => const VerifyPhoneView(),
      binding: AuthBinding(),
    ),

    // Main Routes
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      bindings: [MainBinding(), CategoriesBinding(), UserBinding()],
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const MainView(),
      binding: MainBinding(),
    ),

    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.services,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: AppRoutes.myBookings,
      page: () => const MyBookingsView(),
      binding: MyBookingsBinding(),
    ),

    GetPage(
      name: AppRoutes.offers,
      page: () => const OffersView(),
      binding: OffersBinding(),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: UserBinding(),
    ),

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),

    GetPage(
      name: AppRoutes.providers,
      page: () => const ServiceProvidersView(),
      binding: ServiceProvidersBinding(),
    ),

    GetPage(
      name: AppRoutes.requestService,
      page: () => const RequestServiceView(),
      binding: RequestServiceBinding(),
    ),

    GetPage(
      name: AppRoutes.successPage,
      page: () => const SuccessPageView(),
      binding: SuccessPageBinding(),
    ),

    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),

    // GetPage(
    //   name: AppRoutes.providerDetails,
    //   page: () => const ProviderDetailsView(),
    //   binding: ServiceBinding(),
    // ),

    // GetPage(
    //   name: AppRoutes.bookService,
    //   page: () => const BookServiceView(),
    //   binding: BookingBinding(),
    // ),
    GetPage(
      name: AppRoutes.bookingDetails,
      page: () => const BookingDetailsView(),
      binding: BookingBinding(),
    ),

    GetPage(
      name: AppRoutes.trackProvider,
      page: () => const TrackProviderView(),
      binding: BookingBinding(),
    ),

    GetPage(
      name: AppRoutes.rateService,
      page: () => const RateServiceView(),
      binding: BookingBinding(),
    ),

    // Profile Routes
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressesView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.addAddress,
      page: () => const AddAddressView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.selectLocation,
      page: () => const SelectLocationView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.language,
      page: () => const LanguageView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
      binding: ProfileBinding(),
    ),

    // Search
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),

    GetPage(
      name: AppRoutes.searchResults,
      page: () => const SearchResultsView(),
      binding: SearchBinding(),
    ),

    // Provider Detail
    GetPage(
      name: AppRoutes.providerDetail,
      page: () => ProviderDetailView(
        provider: Get.arguments,
      ), // Provider passed via arguments
      binding: ProviderDetailBinding(),
    ),

    // All Providers
    GetPage(
      name: AppRoutes.allProviders,
      page: () => const AllProvidersView(),
      binding: AllProvidersBinding(),
    ),

    // Offers
    GetPage(
      name: AppRoutes.offers,
      page: () => const OffersView(),
      binding: OffersBinding(),
    ),
  ];
}
