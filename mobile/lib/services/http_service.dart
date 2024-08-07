import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = "https://doggo-api-test.redwave-5a54044b.australiaeast.azurecontainerapps.io";

  static Future<Map<String, dynamic>> login(String username, String password) async {
    const url = '$baseUrl/api/auth/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> fetchDogActivityStatus(DateTime date) async {
    // const url = '$baseUrl/';
    // final response = await http.get(Uri.parse(url));
    //
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception('Failed to fetch dog activity status');
    // }
    print("fetching data $date");
    // Fetch the current steps and total steps from your data source
    int currentSteps = 900; // Replace with actual data fetching
    int totalSteps = 1000; // Replace with actual data fetching
    int calories = 1200;
    double distance = 7;
    return {'currentSteps': currentSteps, 'totalSteps': totalSteps, 'calories': calories, 'distance': distance};
  }

  static Future<Map<String, dynamic>> getRoot() async {
    const url = '$baseUrl/';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }

  static Future<List<dynamic>> fetchMapMarkers(String category) async {
    const url = '$baseUrl/'; // TODO: change to the real url
    // final response = await http.get(Uri.parse(url));
    //
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception('Failed to load markers');
    // }

    // Dummy data representing marker locations
    List<dynamic> dummyData = [
      {
        'lat': 32.0853,
        'lon': 34.7818,
        'category': 'medical',
      },
      {
        'lat': 32.0855,
        'lon': 34.7820,
        'category': 'parks',
      },
      {
        'lat': 32.0857,
        'lon': 34.7822,
        'category': 'pensions',
      },
      {
        'lat': 32.0859,
        'lon': 34.7824,
        'category': 'restaurants',
      },
      {
        'lat': 32.0861,
        'lon': 34.7826,
        'category': 'beauty',
      },
      {
        'lat': 32.0863,
        'lon': 34.7828,
        'category': 'hotels',
      },
    ];

    // Filter data based on category
    List<dynamic> filteredData = dummyData.where((marker) => marker['category'] == category).toList();

    return filteredData;
  }

  static Future<void> sendStepCountToBackend(int stepCount) async {
    final url = Uri.parse('$baseUrl/api/dogs/{dog_id}/fitness/steps');
    // final response = await http.put(url, body: jsonEncode({'steps': stepCount}), headers: {'Content-Type': 'application/json'});
    // if (response.statusCode == 200) {
    //   print('Step count updated successfully');
    // } else {
    //   print('Failed to update step count: ${response.statusCode}');
    // }

    print("send steps to server: $stepCount | $DateTime.timestamp()");
  }

  static Future<void> sendBatteryLevelToBackend(String deviceId, int batteryLevel) async {
    final url = Uri.parse('$baseUrl/api/devices/battery');
    // final response = await http.put(url, body: jsonEncode({'device_id': deviceId, 'timestamp': DateTime.now().toUtc().toIso8601String(), 'battery_level': '$batteryLevel%'}), headers: {'Content-Type': 'application/json'});
    // if (response.statusCode == 200) {
    //   print('Battery level updated successfully');
    // } else {
    //   print('Failed to update battery level: ${response.statusCode}');
    // }

    print("send battery level to server: $batteryLevel | $DateTime.timestamp()");
  }
}
