import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android creates and declares the transactional FCM channel', () {
    const channelId = 'carenet_transactional';
    final activity =
        File(
          'android/app/src/main/java/com/carenet/app/MainActivity.java',
        ).readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final transport =
        File(
          'lib/features/Notifications/data/services/'
          'firebase_notification_transport.dart',
        ).readAsStringSync();
    final notificationIcon = File(
      'android/app/src/main/res/drawable/carenet_notification.xml',
    );

    expect(activity, contains('TRANSACTIONAL_CHANNEL_ID = "$channelId"'));
    expect(activity, contains('createNotificationChannel(channel)'));
    expect(
      manifest,
      contains('com.google.firebase.messaging.default_notification_channel_id'),
    );
    expect(manifest, contains('android:value="$channelId"'));
    expect(manifest, contains('@drawable/carenet_notification'));
    expect(notificationIcon.existsSync(), isTrue);
    expect(transport, contains("'carenet_notification'"));
    expect(transport, contains("'$channelId'"));
  });
}
