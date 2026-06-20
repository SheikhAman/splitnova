import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import '../data/models/config_models.dart';

enum UpdateStatus { noUpdate, optionalUpdate, forceUpdate }

class UpdateInfo {
  final UpdateStatus status;
  final String latestVersion;
  final String updateMessage;
  final String playStoreUrl;

  UpdateInfo({
    required this.status,
    required this.latestVersion,
    required this.updateMessage,
    required this.playStoreUrl,
  });
}

class AppUpdateService extends GetxService {
  /// Checks for updates by first trying the Play Store scraping and falling back to Firestore
  Future<UpdateInfo> checkForUpdate(AppConfig? firestoreConfig) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    
    String latestVersion = '';
    
    // 1. Try to get version from Play Store
    try {
      final response = await http.get(Uri.parse(
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}&hl=en'
      )).timeout(const Duration(seconds: 3)); // Reduced from 10s to 3s

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        // Note: Play Store UI changes frequently. This is a common scraper target.
        // If this fails, we fall back to Firestore.
        final versionElements = document.getElementsByClassName('reAt0');
        if (versionElements.isNotEmpty) {
          latestVersion = versionElements.first.text.trim();
        }
      }
    } catch (e) {
      debugPrint('AppUpdateService - Play Store Scraping Error: $e');
    }

    // 2. Fallback to Firestore if scraping failed or returned empty
    if (latestVersion.isEmpty && firestoreConfig != null) {
      latestVersion = firestoreConfig.latestVersion.toString(); // or convert from int64 to semantic if needed
    }

    if (latestVersion.isEmpty) {
      return UpdateInfo(
        status: UpdateStatus.noUpdate,
        latestVersion: currentVersion,
        updateMessage: '',
        playStoreUrl: firestoreConfig?.playStoreUrl ?? '',
      );
    }

    // 3. Compare versions
    final isNewer = _isVersionNewer(currentVersion, latestVersion);
    
    if (isNewer) {
      if (firestoreConfig?.forceUpdate ?? false) {
        return UpdateInfo(
          status: UpdateStatus.forceUpdate,
          latestVersion: latestVersion,
          updateMessage: firestoreConfig?.updateMessage ?? '',
          playStoreUrl: firestoreConfig?.playStoreUrl ?? '',
        );
      } else {
        return UpdateInfo(
          status: UpdateStatus.optionalUpdate,
          latestVersion: latestVersion,
          updateMessage: firestoreConfig?.updateMessage ?? '',
          playStoreUrl: firestoreConfig?.playStoreUrl ?? '',
        );
      }
    }

    return UpdateInfo(
      status: UpdateStatus.noUpdate,
      latestVersion: currentVersion,
      updateMessage: '',
      playStoreUrl: firestoreConfig?.playStoreUrl ?? '',
    );
  }

  /// Simple semantic version comparison
  bool _isVersionNewer(String current, String latest) {
    try {
      List<int> currentParts = current.split('.').map((e) => int.parse(e)).toList();
      List<int> latestParts = latest.split('.').map((e) => int.parse(e)).toList();

      for (int i = 0; i < latestParts.length; i++) {
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        if (latestParts[i] > currentPart) return true;
        if (latestParts[i] < currentPart) return false;
      }
    } catch (e) {
      // If version format is unusual (like just a build number), do a direct string compare or ignore
      return latest != current;
    }
    return false;
  }
}
