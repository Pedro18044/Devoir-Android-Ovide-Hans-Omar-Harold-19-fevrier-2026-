import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone init
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));

  await _initNotifications();

  runApp(const MyApp());
}

Future<void> _initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(android: androidInit);

  await notifications.initialize(initSettings);

  // Android 13+ notification runtime permission
  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

NotificationDetails _basicDetails() {
  const android = AndroidNotificationDetails(
    'basic_channel',
    'Basic Notifications',
    channelDescription: 'Demo channel for notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  return const NotificationDetails(android: android);
}

Future<void> showImmediate() async {
  await notifications.show(
    1,
    'Immediate Notification',
    'Sa se yon notifikasyon imedya ✅',
    _basicDetails(),
  );
}

Future<void> showScheduled5sec() async {
  final scheduledTime =
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

  await notifications.zonedSchedule(
    2,
    'Scheduled Notification',
    'Li ta dwe parèt apre 5 segonn ⏳',
    scheduledTime,
    _basicDetails(),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> showRepeating1min() async {
  await notifications.periodicallyShow(
    3,
    'Repeating Notification',
    'Sa ap repete chak 1 min 🔁',
    RepeatInterval.everyMinute,
    _basicDetails(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> cancelAll() async {
  await notifications.cancelAll();
}

Future<void> showBigText() async {
  const bigStyle = BigTextStyleInformation(
    'Men yon tèks long pou Big Text Notification. '
    'Rale notification shade la pou w wè tout mesaj la. '
    'Sa itil pou rapèl, mesaj long, elatriye.',
  );

  const android = AndroidNotificationDetails(
    'bigtext_channel',
    'Big Text',
    channelDescription: 'Big text notifications',
    styleInformation: bigStyle,
    importance: Importance.max,
    priority: Priority.high,
  );

  await notifications.show(
    4,
    'Big Text Notification',
    'Rale notification shade la pou wè tèks la',
    const NotificationDetails(android: android),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const NotificationPage(),
    );
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Demo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: showImmediate,
                child: const Text('Immediate Notification'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: showScheduled5sec,
                child: const Text('Scheduled (5 sec)'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: showRepeating1min,
                child: const Text('Repeating (1 min)'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: cancelAll,
                child: const Text('Cancel All'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: showBigText,
                child: const Text('Big Text Notification'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Si Scheduled/Repeating pa parèt sou emulator:\n"
                "Settings → Notifications → App notifications → Notification Demo → Allow",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}