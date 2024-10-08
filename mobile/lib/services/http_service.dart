import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/services/preferences_service.dart';

class HttpService {
  static const String baseUrl = "http://34.230.176.208:5000";

  //--------------------------------------auth--------------------------------------
  static Future<Map<String, dynamic>> login(String email, String password) async  {
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
      //user $userId logged out!
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
      //Register completed
      return jsonDecode(response.body);
    } else {
      //Register error
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
      //User $userId connection status: ${responseData['user_connection']}'
      return responseData['user_connection'] ?? false;
    } else {
      //Failed to check user connection status. Status code: ${response.statusCode}'
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
    required int userId,
    required String description
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
        'user_id': userId,
        'description': description
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
      //collar $collarId configured to dog $dogId
    } else {
      //failed to configure collar $collarId to dog $dogId'
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

  static Future<void> updateUserProfile(int userId, String email, String password, String name, String formattedDateOfBirth, String phoneNumber) async {
    final url = Uri.parse('$baseUrl/api/user/profile');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId.toString(),
        'email': email,
        'password': password,
        'name': name,
        'date_of_birth': formattedDateOfBirth,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      //User profile updated successfully
    } else {
      //Failed to update user profile: ${response.statusCode}
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

  static Future<void> updateDogProfile(int dogId, String name, String breed, String gender, String dateOfBirth, double weight, int height, String description) async {
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
        'image': "",
        'description': description
      }),
    );

    if (response.statusCode == 200) {
      //Dog profile updated successfully'
    } else {
      //Failed to update dog profile: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }

  }

  static Future<bool> isValidPassword (int userId, String password) async {
    final url = Uri.parse('$baseUrl/api/user/check_password?user_id=$userId&password=$password');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["is_valid"];
    } else {
      throw Exception('Failed to fetch dog activity status: ${response.statusCode}');
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
      //favorite place was set successfully
    } else {
      //Failed to set favorite place: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String,dynamic>?> getFavoritePlaceByType(int dogId, String placeType) async {
    final url = Uri.parse('$baseUrl/api/favorite_places/by_type?dog_id=${dogId.toString()}&place_type=$placeType');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if(response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if(response.statusCode == 204) {
      return null;
    } else {
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
      //Step count updated successfully
    } else {
      //Failed to update step count
    }
  }

  static Future<void> sendBatteryLevelToBackend(String dogId, int batteryLevel) async {
    final url = Uri.parse('$baseUrl/api/collar/battery?dog_id=$dogId&battery_level=$batteryLevel');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //Battery level updated successfully
    } else {
      //Failed to update battery level: ${response.statusCode}
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

  static Future<void> addUpdatePension(int dogId, String pensionName, String pensionPhone, double pensionLatitude, double pensionLongitude) async{
    final url = Uri.parse('$baseUrl/api/dog/pension');
    final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
        'dog_id': dogId.toString(),
        'pension_name': pensionName,
        'pension_phone': pensionPhone,
        "pension_latitude": pensionLatitude,
        "pension_longitude": pensionLongitude,
        })
    );

    if (response.statusCode == 200) {
      //Dog pension updated successfully
    } else {
      //Failed to update dog pension: ${response.statusCode}
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
      //Dog vet updated successfully
    } else {
      //Failed to update dog vet: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------medical records--------------------------------------
  static Future<Map<String, dynamic>> getMonthlyMedicalRecords(int dogId, int year, int month) async {
    final url = Uri.parse('$baseUrl/api/dog/medical_records/days?dog_id=$dogId&month=$month&year=$year');
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

  static Future<List<dynamic>> getDailyMedicalRecords(int dogId, String formattedDate) async {
    final url = Uri.parse('$baseUrl/api/dog/medical_records/by_date?dog_id=$dogId&date=$formattedDate');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return  jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> addMedicalRecord(String dogId, Map<String, dynamic> recordData) async {

    final url = Uri.parse('$baseUrl/api/dog/medical_records');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dog_id': dogId,
        ...recordData,
      }),
    );

    if (response.statusCode == 201) {
      //New record created
    } else {
      //Failed to create new record: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> updateMedicalRecord(int recordId, Map<String, dynamic> recordData) async {
    final url = Uri.parse('$baseUrl/api/dog/medical_records');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'record_id': recordId,
        ...recordData,
      }),
    );

    if (response.statusCode == 200) {
      //Record updated successfully
    } else {
      //Failed to update medical record $recordId: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> deleteMedicalRecord(int recordId) async {
    final url = Uri.parse('$baseUrl/api/dog/medical_records?record_id=${recordId.toString()}');
    final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      return;
    } else {
      //Failed to delete medical record $recordId: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> getMedicalRecord(int recordId) async {
    final url = Uri.parse('$baseUrl/api/dog/medical_records?record_id=$recordId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return  jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------vaccinations--------------------------------------
  static Future<List<Map<String, dynamic>>?> getVaccinationsByType(int dogId, String vaccinationType, int limit, int offset) async {
    final url = Uri.parse('$baseUrl/api/dog/vaccinations?dog_id=$dogId&vaccination_type=$vaccinationType&limit=$limit&offset=$offset');
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
      //Failed to get dog vaccinations: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> createNewVaccination(Map<String, dynamic> newVaccination) async {
    final url = Uri.parse('$baseUrl/api/dog/vaccinations');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newVaccination)
    );

    print (response.statusCode);
    if (response.statusCode == 201) {
      return;
    } else {
      //Failed to create dog vaccination: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> updateVaccination(Map<String, dynamic> updatedVaccination) async {
    final url = Uri.parse('$baseUrl/api/dog/vaccinations');
    final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedVaccination)
    );

    print('****************');
    print(response.statusCode);
    print('****************');

    if (response.statusCode == 200) {
      //Dog vaccination updated successfully
      return;
    } else {
      print(jsonDecode(response.body)['error']);
      //Failed to update dog vaccination: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> deleteVaccination(int vaccinationId) async {
    final url = Uri.parse('$baseUrl/api/dog/vaccinations?vaccination_id=$vaccinationId');
    final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      return;
    } else {
      //Failed to delete vaccination $vaccinationId: ${response.statusCode}
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
      //Dog nutrition updated successfully
    } else {
      //Failed to update dog nutrition: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------outdoor activities--------------------------------------
  static Future<List<Map<String, dynamic>>?> getOutdoorActivities(int dogId, int limit, int offset) async {
    final url = Uri.parse('$baseUrl/api/dog/activities/all?dog_id=$dogId&limit=$limit&offset=$offset');
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
      //Failed to get dog activities: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String,dynamic>> getOutdoorActivityInfo(int activityId) async {
    final url = Uri.parse('$baseUrl/api/dog/activities?activity_id=$activityId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      //Failed to fetch activity $activityId info
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
      //Failed to create new activity: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> endActivity(int activityId) async {
    final url = Uri.parse('$baseUrl/api/dog/activities/end?activity_id=${activityId.toString()}');
    final response = await http.put(
        url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //End activity: $activityId
    } else {
      //Failed to create new activity: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
  //--------------------------------------goals--------------------------------------
  static Future<int> getDailyStepsGoal(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/dailyStepsGoal?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['daily_steps_goal'];
    } else {
      //Failed to get dog daily steps goal: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> getGoalInfo(int goalId) async {
    final url = Uri.parse('$baseUrl/api/dog/goals?goal_id=$goalId');
    final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      //Failed to get goal info: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<List<Map<String, dynamic>>?> getGoalsList(int dogId, int limit, int offset) async {
    final url = Uri.parse('$baseUrl/api/dog/goals/all?dog_id=$dogId&limit=$limit&offset=$offset');
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
      //Failed to get dog goals: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<List<Map<String, dynamic>>?> getGoalsTemplatesList(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/goal_templates/all?dog_id=$dogId');
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
      //Failed to get dog goals: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Map<String, dynamic>> getGoalTemplateInfo(int templateId) async {
    final url = Uri.parse('$baseUrl/api/dog/goal_templates?template_id=$templateId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      //Failed to get goal template info: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> createGoal(int dogId, String targetValue, String frequency, String category) async {
    final url = Uri.parse('$baseUrl/api/dog/goals/add');
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dog_id': dogId,
          'target_value': targetValue,
          'frequency': frequency,
          'category': category
        })
    );

    if (response.statusCode == 201) {
      //goal created
      return;
    } else {
      //Failed to create goal: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> updateGoalTemplate(int templateId, String updatedTarget) async {
    final url = Uri.parse('$baseUrl/api/dog/goals?template_id=$templateId&target_value=$updatedTarget');
    final response = await  http.put(
        url,
        headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //goal template $templateId was updated
      return;
    } else {
      //failed to update goal template $templateId : ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> deleteGoalTemplate(int templateId) async {
    final url = Uri.parse('$baseUrl/api/dog/goal_templates?template_id=$templateId');
    final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      return;
    } else {
      //Failed to delete goal template $templateId: ${response.statusCode}
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  //--------------------------------------bcs--------------------------------------
  static Future<int?> getBCS(int dogId) async {
    final url = Uri.parse('$baseUrl/api/dog/bcs?dog_id=$dogId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        return int.parse(response.body);
      } catch(e) {
        return null;
      }
    } else {
      throw Exception('Failed to fetch bcs: ${response.statusCode}');
    }
  }


}
