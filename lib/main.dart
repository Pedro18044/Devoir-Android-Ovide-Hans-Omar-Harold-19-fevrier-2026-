import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone init (pou scheduled / repeating)
  tzdata.initializeTimeZones();
  final localTz = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTz));

  await _initNotifications();
  runApp(const MyApp());
}

Future<void> _initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
  await notifications.initialize(initSettings);

  // Android 13+ permission (si disponib)
  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

NotificationDetails _basicDetails() {
  const android = AndroidNotificationDetails(
    'demo_channel_id',
    'Demo Notifications',
    channelDescription: 'Channel pou demo notifikasyon yo',
    importance: Importance.max,
    priority: Priority.high,
  );
  const ios = DarwinNotificationDetails();
  return const NotificationDetails(android: android, iOS: ios);
}

// 1) Imenyat
Future<void> showImmediate() async {
  await notifications.show(
    1,
    'Notifikasyon Imenyat',
    'Sa parèt touswit lè w peze bouton an.',
    _basicDetails(),
  );
}

// 2) Pwograme (5 segonn pita)
Future<void> showScheduled() async {
  final time = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
  await notifications.zonedSchedule(
    2,
    'Notifikasyon Pwograme',
    'Sa ap parèt 5 segonn apre.',
    time,
    _basicDetails(),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

// 3) Repete (chak minit)
Future<void> showRepeating() async {
  await notifications.periodicallyShow(
    3,
    'Notifikasyon Ki Repete',
    'Sa ap repete chak minit.',
    RepeatInterval.everyMinute,
    _basicDetails(),
    androidAllowWhileIdle: true,
  );
}

// 4) Big Text (tèks long)
Future<void> showBigText() async {
  const longText =
      'Sa se yon notifikasyon ak tèks long. Li itil lè ou vle mete plis detay '
      'pou itilizatè a li san li pa ouvri aplikasyon an. Ou ka elaji notifikasyon '
      'an pou w wè tout mesaj la.';

  const android = AndroidNotificationDetails(
    'demo_channel_id',
    'Demo Notifications',
    channelDescription: 'Channel pou demo notifikasyon yo',
    styleInformation: BigTextStyleInformation(longText),
    importance: Importance.max,
    priority: Priority.high,
  );

  await notifications.show(
    4,
    'Big Text Notification',
    'Elaji notifikasyon an pou w wè tèks long la.',
    const NotificationDetails(android: android),
  );
}

Future<void> cancelAll() async {
  await notifications.cancelAll();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification Demo',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _btn({
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 6),
        Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _btn(
              title: 'Immediate Notification',
              desc: 'Voye yon notifikasyon lokal ki parèt touswit.',
              onTap: showImmediate,
            ),
            _btn(
              title: 'Scheduled Notification',
              desc: 'Voye yon notifikasyon ki parèt 5 segonn pita.',
              onTap: showScheduled,
            ),
            _btn(
              title: 'Repeating Notification',
              desc: 'Voye yon notifikasyon ki repete chak minit.',
              onTap: showRepeating,
            ),
            _btn(
              title: 'Big Text Notification',
              desc: 'Voye yon notifikasyon ak tèks long (BigTextStyle).',
              onTap: showBigText,
            ),
            _btn(
              title: 'Cancel All',
              desc: 'Anile tout notifikasyon yo (si w te mete repeating).',
              onTap: cancelAll,
            ),
          ],
        ),
      ),
    );
  }
}
