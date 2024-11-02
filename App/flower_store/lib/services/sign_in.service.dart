import 'package:flower_store/screens/store.main.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignInService {
  Future<void> loginWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final AccessToken accessToken = result.accessToken!;
        print('Access Token: ${accessToken.token}'); // In ra token
        await sendTokenToBackend(accessToken.token, context);
        
      } else if (result.status == LoginStatus.cancelled) {
        _showErrorDialog(context, 'Đăng nhập đã bị hủy.');
      } else {
        print('Facebook login failed: ${result.status}');
        _showErrorDialog(context, 'Facebook login failed');
      }
    } catch (e) {
      print('Error during Facebook login: $e');
      _showErrorDialog(context, 'Error during Facebook login: $e');
    }
  }

  Future<void> sendTokenToBackend(String token, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.7:3000/api/Accounts/login-facebook'),
      // Uri.parse('http://localhost:3000/api/Accounts/login-facebook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': token}),
    );

    if (response.statusCode == 200) {
      // Thành công
      var responseBody = jsonDecode(response.body);
      String jwtToken = responseBody['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', jwtToken);
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      print('Backend login failed: ${response.statusCode} - ${response.body}');
      _showErrorDialog(context, 'Backend login failed: ${response.statusCode}');
    }
  }

  // Hiển thị dialog lỗi cho người dùng
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }
}
