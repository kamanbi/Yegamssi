class PurchaseConfig {
  PurchaseConfig._();

  /// Google Play Console에 등록된 비소모성 상품 ID (광고 제거)
  static const String removeAdsProductId = 'remove_ads';

  /// 구매 완료 여부 로컬 캐시 키
  static const String premiumStorageKey = 'is_premium_purchased';
}
