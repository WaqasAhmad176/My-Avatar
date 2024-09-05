import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/ApiRequest.dart';
import '../data/ApiResponse.dart';


class ApiService {
  final String _baseUrl = 'https://api.runpod.ai/v2/mvzgtfvqhwdwal/runsync';
  final String _bearerToken = '62QFJDVE6BT56SRAM0JJVQF8EMBW9U5YCNXHWVRS';

  Future<ApiResponse> generateImage(ApiRequest request) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      print("Failed");
      throw Exception('Failed to generate image');
    }
  }
}
