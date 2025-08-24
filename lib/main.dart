import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/app_translations.dart';
import 'app/core/constants/app_constants.dart';
import 'app/data/services/api_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app initialization...');

  // Initialize services
  await initServices();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('🎉 App starting...');
  runApp(KhabirUserApp());
}

Future<void> initServices() async {
  print('🔧 Initializing services...');

  try {
    // Initialize storage service first
    print('📦 Initializing storage service...');
    final storageService = await Get.putAsync(() => StorageService().init());
    print('✅ Storage service initialized successfully');

    // Test storage service
    try {
      print('🧪 Testing storage service...');
      await storageService.saveString('test_init', 'test_value');
      final testValue = storageService.getString('test_init');
      if (testValue == 'test_value') {
        await storageService.remove('test_init');
        print('✅ Storage service test passed');
      } else {
        print('⚠️ Storage service test failed');
      }

      // Print current storage state
      print('📊 Initial Storage State:');
      print('   - Has Token: ${storageService.hasToken}');
      print('   - Has User: ${storageService.hasUser}');
      print(
        '   - Onboarding Completed: ${storageService.isOnboardingCompleted}',
      );
    } catch (testError) {
      print('⚠️ Storage test error: $testError');
    }

    // Initialize API service
    print('🌐 Initializing API service...');
    Get.put(ApiService(), permanent: true);
    print('✅ API service initialized successfully');

    print('🎯 All services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');

    // Create fallback services with proper initialization
    try {
      print('🆘 Creating fallback services...');

      final fallbackStorage = StorageService();
      try {
        await fallbackStorage
            .onInit(); // Ensure SharedPreferences is initialized
        Get.put<StorageService>(fallbackStorage, permanent: true);
        print('✅ Fallback storage service created with SharedPreferences');
      } catch (fallbackStorageError) {
        print(
          '❌ Fallback storage initialization failed: $fallbackStorageError',
        );
        // Put the service anyway, some functionality might still work
        Get.put<StorageService>(fallbackStorage, permanent: true);
        print('⚠️ Fallback storage service created without SharedPreferences');
      }

      Get.put(ApiService(), permanent: true);
      print('⚠️ Fallback services created');
    } catch (fallbackError) {
      print('💥 Even fallback service creation failed: $fallbackError');
    }
  }
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
      locale: const Locale('ar'), // Default to Arabic
      fallbackLocale: const Locale('en'),

      // Routes
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Default transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Unknown route
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const NotFoundView(),
      ),

      // Global bindings
      initialBinding: InitialBinding(),

      // Enable smart management
      smartManagement: SmartManagement.full,

      // Add this to see navigation logs
      enableLog: true,

      // Add route observer for debugging navigation issues
      routingCallback: (routing) {
        print('🛣️ Route changed: ${routing?.current ?? 'unknown'}');
        if (routing?.previous != null) {
          print('   Previous: ${routing?.previous}');
        }
      },
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('🔗 Setting up initial bindings...');

    // Verify services are available
    try {
      final storageService = Get.find<StorageService>();
      print('✅ StorageService is available in InitialBinding');
    } catch (e) {
      print('❌ StorageService not available in InitialBinding: $e');
    }

    try {
      final apiService = Get.find<ApiService>();
      print('✅ ApiService is available in InitialBinding');
    } catch (e) {
      print('❌ ApiService not available in InitialBinding: $e');
    }
  }
}

class NotFoundView extends StatelessWidget {
  const NotFoundView({Key? key}) : super(key: key);

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
            const SizedBox(height: 8),
            Text(
              'page_not_found_description'.tr,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
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
    print('📱 StorageServiceExt: Initializing storage service...');
    try {
      await onInit();
      print('✅ StorageServiceExt: Storage service ready');
      return this;
    } catch (e) {
      print('❌ StorageServiceExt: Initialization failed: $e');
      rethrow;
    }
  }
}
