import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/preferences_service.dart';

class HttpService {
  static const String baseUrl = "http://34.230.176.208:5000";

  //--------------------------------------auth--------------------------------------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/user/login');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) { // user & dog id
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> logout(int userId) async {
    final url = Uri.parse('$baseUrl/api/user/logout?user_id=$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('user $userId logged out!');
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> registerUser(String email, String password, String name, String dateOfBirth, String phoneNumber) async {
    final url = Uri.parse('$baseUrl/api/user/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'date_of_birth': dateOfBirth,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 201) {
      print('Register completed');
      return jsonDecode(response.body);
    } else {
      print('Register error');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<bool> isLoggedIn(int userId) async {
    final url = Uri.parse('$baseUrl/api/user/connection?user_id=$userId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('User $userId connection status: ${responseData['user_connection']}');
      return responseData['user_connection'] ?? false;
    } else {
      print('Failed to check user connection status. Status code: ${response.statusCode}');
      return false;
    }
  }

  //--------------------------------------complete register--------------------------------------
  static Future<int?> addNewDog({
    required String name,
    required String breed,
    required String gender,
    required String dateOfBirth,
    required double weight,
    required double height,
    required int userId
  }) async {
    final url = Uri.parse('$baseUrl/api/dog/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'breed': breed,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'weight': weight,
        'height': height,
        'user_id': userId
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final dogId = responseData['dog_id'];
      PreferencesService.saveDogId(dogId);
      return dogId;  // Return the dogId
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> configureCollar(int dogId, String collarId) async{
    final url = Uri.parse('$baseUrl/api/collar/add');
    final response = await  http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'collar_id': collarId,
        'dog_id': dogId,
      })
    );

    if (response.statusCode == 200) {
      print('collar $collarId configured to dog $dogId');
    } else {
      print('failed to configure collar $collarId to dog $dogId');
      throw Exception(jsonDecode(response.body)['error']);
    }

  }

  //--------------------------------------user info--------------------------------------
  static Future<Map<String, dynamic>> getUserInfo(int userId) async {
    final url = Uri.parse('$baseUrl/api/user/profile?user_id=$userId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> updateUserProfile(int userId, String email, String password, String name, DateTime dateOfBirth, String phoneNumber) async {
    final url = Uri.parse('$baseUrl/api/user/profile');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId.toString(),
        'email': email,
        'password': password,
        'name': name,
        'date_of_birth': "${dateOfBirth.day.toString().padLeft(2, '0')}.${dateOfBirth.month.toString().padLeft(2, '0')}.${dateOfBirth.year}",
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      print('User profile updated successfully');
    } else {
      print('Failed to update user profile: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }

  }

  //--------------------------------------dog info--------------------------------------
  static Future<Map<String, dynamic>> getDogInfo(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/profile?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> updateDogProfile(int dogId, String name, String breed, String gender, String dateOfBirth, double weight, int height) async {
    final url = Uri.parse('$baseUrl/api/dog/profile');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dog_id': dogId.toString(),
        'name': name,
        'breed': breed,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'weight': weight,
        'height': height,
        'image': ""
      }),
    );

    if (response.statusCode == 200) {
      print('Dog profile updated successfully');
    } else {
      print('Failed to update dog profile: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }

  }

  //--------------------------------------fitness--------------------------------------
  static Future<Map<String, dynamic>> fetchDogActivityStatus(String formattedDate, int dogId) async {

    final url = Uri.parse('$baseUrl/api/dog/fitness?dog_id=$dogId&date=$formattedDate');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch dog activity status: ${response.statusCode}');
    }
  }

  //--------------------------------------dog friendly places--------------------------------------
  static Future<List<dynamic>> fetchMapMarkers(String category) async {
    final url = Uri.parse('$baseUrl/api/places/by_type?place_type=${category.toLowerCase()}');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load markers');
    }
  }

  //--------------------------------------favorite places--------------------------------------
  static Future<void> setFavoritePlace(String dogId, String placeName, double placeLatitude, double placeLongitude, String address, String placeType) async {
    final url = Uri.parse('$baseUrl/api/favorite_places');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dog_id': dogId,
        'place_name': placeName,
        'place_latitude': placeLatitude,
        'place_longitude': placeLongitude,
        'address': address,
        'place_type': placeType.toLowerCase()
      }),
    );

    if (response.statusCode == 200) {
      print('favorite place was set successfully');
    } else {
      print('Failed to set favorite place: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------collar data--------------------------------------
  static Future<void> sendStepCountToBackend(String dogId, int stepCount) async {
    final url = Uri.parse('$baseUrl/api/dog/fitness?dog_id=$dogId&steps=$stepCount');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Step count updated successfully');
    } else {
      print('Failed to update step count: ${response.statusCode}');
    }
  }

  static Future<void> sendBatteryLevelToBackend(String dogId, int batteryLevel) async {
    final url = Uri.parse('$baseUrl/api/collar/battery?dog_id=$dogId&battery_level=$batteryLevel');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Battery level updated successfully');
    } else {
      print('Failed to update battery level: ${response.statusCode}');
    }
  }

  static Future<String> getCollarId(String dogId) async {
    final url = Uri.parse('$baseUrl/api/collar/get?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['collar_id'];
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<int> getBatteryLevel(String collarId) async {
    final url = Uri.parse('$baseUrl/api/collar/battery?collar_id=$collarId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if(response.statusCode == 200) {
      return jsonDecode(response.body)['battery_level'];
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> getConnectionStatus(String collarId) async {
    final url = Uri.parse('$baseUrl/api/collar/connectionStatus?collar_id=$collarId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if(response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<bool> isCollarAvailable(String collarId) async {
    print(collarId);
    final url = Uri.parse('$baseUrl/api/collar/availability?collar_id=$collarId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if(response.statusCode == 200) {
      return jsonDecode(response.body)['Available'];
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
}

  //--------------------------------------faq--------------------------------------
  static Future<Map<String, dynamic>> getFrequentlyQuestions() async {
    final url = Uri.parse('$baseUrl/api/faq/questions');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<String> getAnswer(String questionId) async {
    final url = Uri.parse('$baseUrl/api/faq/answer?faq_id=$questionId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------pension--------------------------------------
  static Future<Map<String, dynamic>?> getPension(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/pension?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return  jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return null;
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> addUpdatePension(int dogId, String pensionName, double pensionLatitude, double pensionLongitude) async{
    final url = Uri.parse('$baseUrl/api/dog/pension');
    print('in http service update pension: ${dogId.toString()}, $pensionName, $pensionLatitude, $pensionLongitude');
    final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
        'dog_id': dogId.toString(),
        'pension_name': pensionName,
        "pension_latitude": pensionLatitude,
        "pension_longitude": pensionLongitude,
        })
    );

    if (response.statusCode == 200) {
      print('Dog pension updated successfully');
    } else {
      print('Failed to update dog pension: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------vet--------------------------------------
  static Future<Map<String, dynamic>?> getVet(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/vet?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return  jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return null;
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> addUpdateVet(int dogId, String vetName, String vetPhone, double vetLatitude, double vetLongitude) async{
    final url = Uri.parse('$baseUrl/api/dog/vet');
    final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dog_id': dogId.toString(),
          'vet_name': vetName,
          'vet_phone': vetPhone,
          "vet_latitude": vetLatitude,
          "vet_longitude": vetLongitude,
        })
    );

    if (response.statusCode == 200) {
      print('Dog vet updated successfully');
    } else {
      print('Failed to update dog vet: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------nutrition--------------------------------------
  static Future<Map<String,dynamic>?> getNutritionData(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/nutrition?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return null;
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> addUpdateNutrition(int dogId, String foodBrand, String foodType, int foodAmountGrams, int dailySnacks, String notes) async {
    final url = Uri.parse('$baseUrl/api/dog/nutrition');
    print('in http service update nutrition: ${dogId.toString()}, $foodBrand, $foodType, ${foodAmountGrams.toString()}, ${dailySnacks.toString()}');
    final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dog_id': dogId.toString(),
          'food_brand': foodBrand,
          'food_type': foodType,
          'food_amount_grams': foodAmountGrams,
          'daily_snacks': dailySnacks,
          'notes': notes
        })
    );

    if (response.statusCode == 201) {
      print('Dog nutrition updated successfully');
    } else {
      print('Failed to update dog nutrition: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------outdoor activities--------------------------------------
  static Future<List<Map<String, dynamic>>?> getAllOutdoorActivities(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/activities/all?dog_id=$dogId');
    final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> decodedData = jsonDecode(response.body);
      return decodedData.cast<Map<String, dynamic>>();
    } else if(response.statusCode == 204) {
      return null;
    } else {
      print('Failed to get dog activities: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<int> startNewActivity(int dogId, String activityType) async {
    final url = Uri.parse('$baseUrl/api/dog/activities?dog_id=$dogId&activity_type=${activityType.toLowerCase()}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['activity_id'];
    } else {
      print('Failed to create new activity: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> endActivity(int activity_id) async {
    final url = Uri.parse('$baseUrl/api/dog/activities/end?activity_id=${activity_id.toString()}');
    final response = await http.put(
        url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('End activity: $activity_id');
    } else {
      print('Failed to create new activity: ${response.statusCode}');
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
  //--------------------------------------goals--------------------------------------
  static Future<int> getDailyStepsGoal(int dogId) async { //TODO: check after backend implementation
    // final url = Uri.parse('$baseUrl/api/dog/dailyStepsGoal?dog_id=$dogId');
    // final response = await http.get(
    //   url,
    //   headers: {'Content-Type': 'application/json'},
    // );
    //
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body)['daily_steps_goal'];
    // } else {
    //   print('Failed to get dog daily steps goal: ${response.statusCode}');
    //   throw Exception(jsonDecode(response.body)['error']);
    // }
    return 2000;
  }
  //--------------------------------------test--------------------------------------
  static Future<Map<String, dynamic>> getRoot() async {
    final url = Uri.parse('$baseUrl/');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }

}
