import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseMessagingService extends GetxService {
  static FirebaseMessagingService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Topic to subscribe to
  static const String userTopic = 'channel_users';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeFirebaseMessaging();
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      print('🔥 Initializing Firebase Messaging...');

      // Request permission for notifications
      await _requestPermission();

      // Get FCM token
      await _getFCMToken();

      // Subscribe to user topic
      await subscribeToUserTopic();

      // Set up message handlers
      _setupMessageHandlers();

      print('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      print('❌ Firebase Messaging initialization failed: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      print(
        '📱 Notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Provisional notification permission granted');
      } else {
        print('❌ Notification permission denied');
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('🔑 FCM Token: $token');
        // You can save this token to your backend or local storage
        // await _saveTokenToBackend(token);
      } else {
        print('❌ Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Subscribe to user topic
  Future<void> subscribeToUserTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic(userTopic);
      print('✅ Successfully subscribed to topic: $userTopic');
    } catch (e) {
      print('❌ Error subscribing to topic $userTopic: $e');
    }
  }

  /// Unsubscribe from user topic
  Future<void> unsubscribeFromUserTopic() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(userTopic);
      print('✅ Successfully unsubscribed from topic: $userTopic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $userTopic: $e');
    }
  }

  /// Set up message handlers
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Received foreground message: ${message.messageId}');
      print('📨 Message data: ${message.data}');
      print('📨 Message notification: ${message.notification?.title}');
      print('📨 Message notification body: ${message.notification?.body}');

      // Handle the message here
      _handleForegroundMessage(message);
    });

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 App opened from background message: ${message.messageId}');
      print('📨 Message data: ${message.data}');

      // Handle the message here
      _handleBackgroundMessage(message);
    });

    // Handle messages when app is terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📨 App opened from terminated state: ${message.messageId}');
        print('📨 Message data: ${message.data}');

        // Handle the message here
        _handleTerminatedMessage(message);
      }
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // Show in-app notification or handle the message
    // You can use Get.snackbar or show a custom dialog
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    // Navigate to specific screen or handle the message
    // You can use Get.toNamed() to navigate
    print('🔄 Handling background message: ${message.data}');
  }

  /// Handle terminated messages
  void _handleTerminatedMessage(RemoteMessage message) {
    // Handle message when app was terminated
    print('🔄 Handling terminated message: ${message.data}');
  }

  /// Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting current token: $e');
      return null;
    }
  }

  /// Refresh FCM token
  Future<void> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      String? newToken = await _firebaseMessaging.getToken();
      if (newToken != null) {
        print('🔄 FCM Token refreshed: $newToken');
        // Update token in your backend
        // await _updateTokenInBackend(newToken);
      }
    } catch (e) {
      print('❌ Error refreshing token: $e');
    }
  }
}

/// Top-level function to handle background messages
/// This function must be top-level (not a class method) to work properly
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Handling background message: ${message.messageId}');
  print('📨 Message data: ${message.data}');
  print('📨 Message notification: ${message.notification?.title}');

  // Handle background message here
  // Note: You cannot use GetX or UI components in background handler
}
