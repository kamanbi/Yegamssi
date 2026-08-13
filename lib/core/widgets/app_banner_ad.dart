import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../l10n/app_localizations.dart';
import '../config/admob_config.dart';
import '../purchase/premium_provider.dart';

class AppBannerAd extends ConsumerStatefulWidget {
  const AppBannerAd({super.key, this.enabled = true});

  static const double slotHeight = 50;

  final bool enabled;

  @override
  ConsumerState<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends ConsumerState<AppBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled && !ref.read(premiumNotifierProvider)) {
      _loadAd();
    }
  }

  @override
  void didUpdateWidget(covariant AppBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled == widget.enabled) return;

    if (!widget.enabled) {
      _disposeAd();
      return;
    }
    if (!ref.read(premiumNotifierProvider)) {
      _loadAd();
    }
  }

  void _loadAd() {
    if (_bannerAd != null) return;

    final bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || !widget.enabled) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );
    _bannerAd = bannerAd;
    bannerAd.load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(premiumNotifierProvider, (previous, next) {
      if (next) {
        _disposeAd();
      } else if (widget.enabled) {
        _loadAd();
      }
    });
    final isPremium = ref.watch(premiumNotifierProvider);
    if (!widget.enabled || isPremium) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      return SizedBox(
        width: double.infinity,
        height: AppBannerAd.slotHeight,
        child: Center(
          child: Text(
            AppLocalizations.of(context).loadingAd,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white38),
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
