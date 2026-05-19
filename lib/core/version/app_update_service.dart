import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';

const _androidPlatform = 'android';
const _defaultPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.yegamssi.yegamssi';

class AppUpdateDecision {
  const AppUpdateDecision({
    required this.currentVersion,
    required this.latestVersion,
    required this.minimumVersion,
    required this.storeUrl,
    required this.requiresUpdate,
    required this.recommendsUpdate,
  });

  final String currentVersion;
  final String latestVersion;
  final String minimumVersion;
  final String storeUrl;
  final bool requiresUpdate;
  final bool recommendsUpdate;

  bool get shouldPrompt => requiresUpdate || recommendsUpdate;
}

class AppUpdateService {
  const AppUpdateService();

  static String get defaultPlayStoreUrl => _defaultPlayStoreUrl;

  Future<AppUpdateDecision?> check() async {
    if (!Platform.isAndroid) {
      return null;
    }
    if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
      debugPrint('[AppUpdate] Supabase config is empty.');
      return null;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final policy = await SupabaseConfig.client
          .from('app_version_policies')
          .select()
          .eq('platform', _androidPlatform)
          .eq('enabled', true)
          .limit(1)
          .maybeSingle();

      if (policy == null) {
        debugPrint('[AppUpdate] No enabled update policy.');
        return null;
      }

      final latestVersion = _readString(policy['latest_version']);
      final minimumVersion = _readString(policy['minimum_version']);
      if (latestVersion == null || minimumVersion == null) {
        debugPrint('[AppUpdate] Update policy version is incomplete.');
        return null;
      }

      final currentVersion = _AppVersion.fromPackageInfo(packageInfo);
      final latestAppVersion = _AppVersion.parse(
        latestVersion,
        buildNumber: _readInt(policy['latest_build_number']),
      );
      final minimumAppVersion = _AppVersion.parse(
        minimumVersion,
        buildNumber: _readInt(policy['minimum_build_number']),
      );
      final requiresUpdate = currentVersion.compareTo(minimumAppVersion) < 0;
      final recommendsUpdate = currentVersion.compareTo(latestAppVersion) < 0;
      if (!requiresUpdate && !recommendsUpdate) {
        return null;
      }

      return AppUpdateDecision(
        currentVersion: currentVersion.label,
        latestVersion: latestAppVersion.label,
        minimumVersion: minimumAppVersion.label,
        storeUrl: _readString(policy['store_url']) ?? _defaultPlayStoreUrl,
        requiresUpdate: requiresUpdate,
        recommendsUpdate: recommendsUpdate,
      );
    } catch (error, stackTrace) {
      debugPrint('[AppUpdate] Policy check failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> hasPlayCoreUpdate() async {
    final info = await _readPlayCoreInfo();
    return info != null && _hasPlayCoreUpdate(info);
  }

  Future<bool> tryPlayCoreUpdate() async {
    final info = await _readPlayCoreInfo();
    if (info == null || !_hasPlayCoreUpdate(info)) {
      return false;
    }
    return _runAllowedPlayCoreUpdate(info);
  }

  Future<AppUpdateInfo?> _readPlayCoreInfo() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      return await InAppUpdate.checkForUpdate();
    } catch (error) {
      debugPrint('[AppUpdate] Play Core check failed: $error');
      return null;
    }
  }

  bool _hasPlayCoreUpdate(AppUpdateInfo info) {
    return info.updateAvailability == UpdateAvailability.updateAvailable ||
        info.updateAvailability ==
            UpdateAvailability.developerTriggeredUpdateInProgress;
  }

  Future<bool> _runAllowedPlayCoreUpdate(AppUpdateInfo info) async {
    try {
      if (info.immediateUpdateAllowed ||
          info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress) {
        final result = await InAppUpdate.performImmediateUpdate();
        return result == AppUpdateResult.success;
      }

      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result != AppUpdateResult.success) {
          return false;
        }
        await InAppUpdate.completeFlexibleUpdate();
        return true;
      }
    } catch (error) {
      debugPrint('[AppUpdate] Play Core update failed: $error');
    }

    return false;
  }

  String? _readString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int? _readInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString().trim());
  }
}

class _AppVersion implements Comparable<_AppVersion> {
  const _AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.buildNumber,
  });

  final int major;
  final int minor;
  final int patch;
  final int? buildNumber;

  String get label {
    final semver = '$major.$minor.$patch';
    final build = buildNumber;
    return build == null ? semver : '$semver+$build';
  }

  static _AppVersion fromPackageInfo(PackageInfo packageInfo) {
    return parse(
      packageInfo.version,
      buildNumber: int.tryParse(packageInfo.buildNumber),
    );
  }

  static _AppVersion parse(String rawVersion, {int? buildNumber}) {
    final parts = rawVersion.trim().split('+');
    final version = parts.first;
    final parsedBuildNumber =
        buildNumber ??
        (parts.length > 1 ? int.tryParse(parts[1].trim()) : null);
    final segments = version
        .split('.')
        .map((segment) => int.tryParse(segment.trim()) ?? 0)
        .toList(growable: true);
    while (segments.length < 3) {
      segments.add(0);
    }
    return _AppVersion(
      major: segments[0],
      minor: segments[1],
      patch: segments[2],
      buildNumber: parsedBuildNumber,
    );
  }

  @override
  int compareTo(_AppVersion other) {
    final semanticComparison = _compareParts(
      [major, minor, patch],
      [other.major, other.minor, other.patch],
    );
    if (semanticComparison != 0) {
      return semanticComparison;
    }
    final leftBuild = buildNumber;
    final rightBuild = other.buildNumber;
    if (leftBuild == null || rightBuild == null) {
      return 0;
    }
    return leftBuild.compareTo(rightBuild);
  }

  static int _compareParts(List<int> lhs, List<int> rhs) {
    for (var index = 0; index < lhs.length; index++) {
      final comparison = lhs[index].compareTo(rhs[index]);
      if (comparison != 0) {
        return comparison;
      }
    }
    return 0;
  }
}
