import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/app_translations.dart';
import 'app/core/constants/app_constants.dart';
import 'app/core/config/firebase_config.dart';
import 'app/data/services/api_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/data/services/firebase_messaging_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app...');

  // Initialize Firebase
  await _initializeFirebase();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('🎉 App starting...');
  runApp(const KhabirUserApp());
}

/// Initialize Firebase
Future<void> _initializeFirebase() async {
  try {
    print('🔥 Initializing Firebase...');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: defaultTargetPlatform == TargetPlatform.android
          ? androidFirebaseOptions
          : iosFirebaseOptions,
    );

    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
}

class KhabirUserApp extends StatelessWidget {
  const KhabirUserApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        _loadLanguage();
        return;
      }

      print('🔧 Initializing services...');

      // Initialize storage service
      await Get.putAsync(
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

      // Initialize Firebase Messaging service
      Get.put(
        FirebaseMessagingService(),
        permanent: !kDebugMode, // Not permanent in debug mode
      );
      print('✅ Firebase Messaging service initialized');

      // Load saved language
      _loadLanguage();
    } catch (e) {
      print('❌ Service initialization failed: $e');
      // Create fallback services
      Get.put(StorageService(), permanent: !kDebugMode);
      Get.put(ApiService(), permanent: !kDebugMode);
      Get.put(FirebaseMessagingService(), permanent: !kDebugMode);
      print('⚠️ Fallback services created');
    }
  }

  void _loadLanguage() {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storageService = Get.find<StorageService>();
        final savedLanguage = storageService.getLanguage();
        print('🌐 Loading saved language: $savedLanguage');

        // Update the locale
        Get.updateLocale(Locale(savedLanguage));
      }
    } catch (e) {
      print('❌ Error loading language: $e');
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
