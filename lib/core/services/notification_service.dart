import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Background messages are automatically shown by FCM on Android.
  // This handler runs for data-only messages in the background.
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'vhandar_high_importance',
    'Vhandar Notifications',
    description: 'Notifications for orders, offers and updates',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> initialize() async {
    await _createAndroidChannel();
    await _requestPermissions();
    _registerHandlers();
    await _logToken();
  }

  Future<void> _createAndroidChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _registerHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Tapped while app in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // App launched from a terminated-state notification
    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleMessageTap(message);
    });
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/launcher_icon',
        ),
      ),
      payload: message.data.toString(),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Notification tapped: ${response.payload}');
    // TODO: navigate based on payload
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint('[FCM] Message tapped: ${message.data}');
    // TODO: navigate based on message.data
  }

  Future<void> _logToken() async {
    final token = await _messaging.getToken();
    debugPrint('[FCM] Token: $token');

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      // TODO: send updated token to backend
    });
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
