import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/app_translations.dart';
import 'app/core/constants/app_constants.dart';
import 'app/data/services/api_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app...');

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('🎉 App starting...');
  runApp(const KhabirUserApp());
}

class KhabirUserApp extends StatelessWidget {
  const KhabirUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building main app...');

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,

      // Internationalization
      translations: AppTranslations(),
      locale: Get.deviceLocale ?? const Locale('ar'),
      fallbackLocale: const Locale('en'),

      // Routes
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Error handling
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const NotFoundView(),
      ),

      // Bindings
      initialBinding: InitialBinding(),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('🔗 Setting up initial bindings...');

    // Initialize services here instead of main()
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      // Check if already initialized
      if (Get.isRegistered<StorageService>()) {
        print('✅ Services already initialized');
        return;
      }

      print('🔧 Initializing services...');

      // Initialize storage service
      final storageService = await Get.putAsync(
        () => StorageService().init(),
        permanent: !kDebugMode, // Not permanent in debug mode
      );
      print('✅ Storage service initialized');

      // Initialize API service
      Get.put(
        ApiService(),
        permanent: !kDebugMode, // Not permanent in debug mode
      );
      print('✅ API service initialized');
    } catch (e) {
      print('❌ Service initialization failed: $e');
      // Create fallback services
      Get.put(StorageService(), permanent: !kDebugMode);
      Get.put(ApiService(), permanent: !kDebugMode);
      print('⚠️ Fallback services created');
    }
  }
}

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('page_not_found'.tr)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'page_not_found'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppPages.initial),
              child: Text('go_home'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to help with service initialization
extension StorageServiceExt on StorageService {
  Future<StorageService> init() async {
    print('📱 Initializing storage...');
    try {
      await onInit();
      print('✅ Storage ready');
      return this;
    } catch (e) {
      print('❌ Storage failed: $e');
      rethrow;
    }
  }
}
