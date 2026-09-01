import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../services/firebase_service.dart';

class PaddleService extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  /// Requests a secure checkout URL for ANY amount.
  /// This requires a backend (Vercel/Netlify) to protect your Paddle API Key.
  Future<String?> getCheckoutUrl(double amount, String currency) async {
    try {
      final backendUrl = _firebaseService.supportConfig?.donation.paddleBackendUrl;
      
      if (backendUrl == null || backendUrl.isEmpty) {
        debugPrint('PaddleService: Backend URL is not configured in Firestore');
        return null;
      }

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'app_name': _firebaseService.appConfig?.appName ?? 'Unknown App',
          'package_id': _firebaseService.packageName,
          'product_name': 'Support ${_firebaseService.appConfig?.appName ?? 'Developer'}',
          'metadata': {
            'origin': 'mobile_app',
            'note': 'Support from ${_firebaseService.appConfig?.appName}',
          }
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['checkout_url'] as String?;
      } else {
        debugPrint('PaddleService Backend Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('PaddleService Error: $e');
      return null;
    }
  }

  Future<bool> launchCheckout(String url) async {
    if (url.isEmpty) return false;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
    }
    return false;
  }
}
