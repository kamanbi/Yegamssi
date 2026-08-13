import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BannerAdOwner { home, activitySheet }

final bannerAdOwnerProvider = StateProvider<BannerAdOwner>(
  (_) => BannerAdOwner.home,
);
