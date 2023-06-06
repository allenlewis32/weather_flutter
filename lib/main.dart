import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  String? result;
  late TextEditingController locationFieldController;

  @override
  void initState() {
    super.initState();
    locationFieldController = TextEditingController();
  }

  @override
  void dispose() {
    locationFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Weather'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Weather',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                  ),
                ),
                const SizedBox(
                  height: 36,
                ),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Location',
                    hintText: 'Enter Location',
                  ),
                  controller: locationFieldController,
                  autofocus: false,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: get,
                  child: const Text(
                    'Get',
                    style: TextStyle(fontSize: 24, height: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                if (result != null) ...[
                  ElevatedButton(
                    onPressed: reset,
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 24, height: 1.5),
                    ),
                  ),
                  Text(
                    result!,
                    style: const TextStyle(fontSize: 24, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      result = null;
      locationFieldController.value = TextEditingValue.empty;
    });
  }

  void get() async {
    var url =
        'https://api.openweathermap.org/data/2.5/weather?appid=8543f6270e23784de12f4f571533d422&q=${locationFieldController.value.text}';
    final response = await http.get(Uri.parse(url));
    setState(() {
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        result = 'Temperature: ${convertTemperature(json['main']['temp'])}\n'
            'Feels like: ${convertTemperature(json['main']['feels_like'])}\n'
            'Minimum temperature: ${convertTemperature(json['main']['temp_min'])}\n'
            'Maximum temperature: ${convertTemperature(json['main']['temp_max'])}\n'
            'Pressure: ${json['main']['pressure']}hPa\n'
            'Humidity: ${json['main']['humidity']}%\n'
            'Clouds: ${json['weather'][0]['description']}';
      } else {
        result = 'Error!';
      }
    });
  }

  String convertTemperature(double value) {
    return '${(value / 10).toStringAsFixed(2)}\u2103';
  }
}
