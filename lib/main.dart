import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey();

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
      scaffoldMessengerKey: snackBarKey,
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
                  onPressed: getFromInput,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      'Get',
                      style: TextStyle(fontSize: 24, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: getFromLocation,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      'Get From Current Location',
                      style: TextStyle(fontSize: 24, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (result != null) ...[
                  ElevatedButton(
                    onPressed: reset,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 24, height: 1.5),
                      ),
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

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      const snackBar = SnackBar(
        content: Text('Location services are disabled. Please enable them.'),
      );
      snackBarKey.currentState?.showSnackBar(snackBar);
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        const snackBar = SnackBar(
          content: Text('Location permissions are needed to continue.'),
        );
        snackBarKey.currentState?.showSnackBar(snackBar);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      const snackBar = SnackBar(
        content: Text(
            "Location permissions are needed to continue. Enable permissions from settings"),
      );
      snackBarKey.currentState?.showSnackBar(snackBar);
    }
    return true;
  }

  void getFromLocation() async {
    if (!await handleLocationPermission()) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var longitude = position.longitude;
    var latitude = position.latitude;
    var url = '$baseUrl&lon=$longitude&lat=$latitude';
    get(url);
  }

  final baseUrl =
      'https://api.openweathermap.org/data/2.5/weather?appid=8543f6270e23784de12f4f571533d422';

  void getFromInput() async {
    var url = '$baseUrl&q=${locationFieldController.value.text}';
    await get(url);
  }

  Future get(String url) async {
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
