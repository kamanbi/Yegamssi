import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_config.dart';

enum SupportAdResult { shown, skippedPremium, loadFailed, showFailed }

class SupportInterstitialAdService {
  SupportInterstitialAdService._();

  static const Duration _loadTimeout = Duration(seconds: 6);

  static Future<SupportAdResult> show({required bool isPremium}) async {
    if (isPremium) {
      return SupportAdResult.skippedPremium;
    }

    final ad = await _load();
    if (ad == null) {
      return SupportAdResult.loadFailed;
    }

    final completer = Completer<SupportAdResult>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(SupportAdResult.shown);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Support interstitial failed to show: ${error.message}');
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(SupportAdResult.showFailed);
        }
      },
    );

    unawaited(ad.show());
    return completer.future;
  }

  static Future<InterstitialAd?> _load() {
    final completer = Completer<InterstitialAd?>();
    Timer? timeout;

    timeout = Timer(_loadTimeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          timeout?.cancel();
          if (!completer.isCompleted) {
            completer.complete(ad);
            return;
          }
          ad.dispose();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Support interstitial failed to load: ${error.message}');
          timeout?.cancel();
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
    );

    return completer.future;
  }
}
