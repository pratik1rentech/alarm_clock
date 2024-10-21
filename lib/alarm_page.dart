import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  static const platform = MethodChannel('com.example.alarm/setAlarm');

  Future<void> setAlarm(String time) async {
    try {
      final String result = await platform.invokeMethod('setAlarm', {"time": time});
      print(result);
    } on PlatformException catch (e) {
      print("Failed to set alarm: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController timeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Enter alarm time in 24 hour formate(HH:mm)'),
            ),
            ElevatedButton(
              onPressed: () {
                setAlarm(timeController.text);
              },
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}