import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/version/app_update_service.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../l10n/app_localizations.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  static const String _homepage = 'https://yegamssi.netlify.app/';
  static const String _privacyPolicy = 'https://yegamssi.netlify.app/privacy';
  static const String _email = 'kamanbi23@naver.com';
  static const double _baseBottomClearance = 61;
  static const double _qrSize = 236;

  @override
  Widget build(BuildContext context) {
    final versionFuture = PackageInfo.fromPlatform();
    final l10n = AppLocalizations.of(context);
    // 외부 ShellRoute의 bottomNavigationBar(탭바+광고배너)는 extendBody로 인해
    // 이 화면의 콘텐츠 위에 겹쳐지므로, 시스템 네비게이션 바 높이까지 더해 가려지지 않게 함.
    final bottomClearance =
        _baseBottomClearance + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.settingsAppInfoTitle),
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          const _InfoLinkCard(),
          const SizedBox(height: AppSpacing.x3),
          _VersionCard(versionFuture: versionFuture),
          const SizedBox(height: AppSpacing.x3),
          const _DataSourceSection(),
          SizedBox(height: bottomClearance),
        ],
      ),
    );
  }

  static Future<bool> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }

    await Clipboard.setData(ClipboardData(text: url));
    return false;
  }

  static Future<void> _copyStoreLink(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: AppUpdateService.defaultPlayStoreUrl),
    );
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.appInfoStoreLinkCopied)));
  }

  static Future<void> _openStore(BuildContext context) async {
    final launched = await _launchUrl(AppUpdateService.defaultPlayStoreUrl);
    if (launched || !context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.appInfoStoreLinkCopied)));
  }

  static Future<void> _showStoreQrDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const _StoreQrDialog(),
    );
  }
}

class _InfoLinkCard extends StatelessWidget {
  const _InfoLinkCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            title: l10n.appInfoHomepage,
            description: l10n.appInfoHomepageDescription,
            onTap: () => AppInfoScreen._launchUrl(AppInfoScreen._homepage),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: l10n.appInfoPrivacy,
            description: l10n.appInfoPrivacyDescription,
            onTap: () => AppInfoScreen._launchUrl(AppInfoScreen._privacyPolicy),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: l10n.appInfoEmail,
            description: l10n.appInfoEmailDescription,
            onTap: () =>
                AppInfoScreen._launchUrl('mailto:${AppInfoScreen._email}'),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: l10n.appInfoShare,
            description: l10n.appInfoShareDescription,
            trailingIcon: Icons.qr_code_2_rounded,
            onTap: () => AppInfoScreen._showStoreQrDialog(context),
          ),
        ],
      ),
    );
  }
}

class _StoreQrDialog extends StatelessWidget {
  const _StoreQrDialog();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: PremiumCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.appInfoShare,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.title(brightness),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appInfoShareQrDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.body(brightness),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: QrImageView(
                  data: AppUpdateService.defaultPlayStoreUrl,
                  size: AppInfoScreen._qrSize,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => AppInfoScreen._copyStoreLink(context),
                    child: Text(l10n.appInfoCopyLink),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => AppInfoScreen._openStore(context),
                    child: Text(l10n.appInfoOpenStore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.versionFuture});

  final Future<PackageInfo> versionFuture;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: FutureBuilder<PackageInfo>(
        future: versionFuture,
        builder: (context, snapshot) {
          final versionText = snapshot.hasData
              ? l10n.appInfoCurrentVersion(
                  snapshot.data!.version,
                  snapshot.data!.buildNumber,
                )
              : l10n.appInfoCheckingVersion;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appInfoVersionTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.title(brightness),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                versionText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.body(brightness),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DataSourceSection extends StatelessWidget {
  const _DataSourceSection();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);
    final titleColor = AppColors.title(brightness);
    final bodyColor = AppColors.body(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.appInfoDataSource,
            style: TextStyle(
              color: titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SourceRowWithLogo(
                sourceName: l10n.appInfoKma,
                description: l10n.appInfoKmaDescription,
                logoAsset: 'assets/images/kogl_type0_ko.png',
                titleColor: titleColor,
                bodyColor: bodyColor,
              ),
              Divider(height: 24, color: Theme.of(context).dividerColor),
              _SourceRowWithLogo(
                sourceName: l10n.appInfoAirKorea,
                description: l10n.appInfoAirKoreaDescription,
                logoAsset: 'assets/images/kogl_type3.png',
                titleColor: titleColor,
                bodyColor: bodyColor,
              ),
              Divider(height: 24, color: Theme.of(context).dividerColor),
              _SourceRow(
                sourceName: l10n.appInfoOpenWeather,
                description: l10n.appInfoOpenWeatherDescription,
                titleColor: titleColor,
                bodyColor: bodyColor,
              ),
              Divider(height: 24, color: Theme.of(context).dividerColor),
              _SourceRow(
                sourceName: l10n.appInfoNominatim,
                description: l10n.appInfoNominatimDescription,
                titleColor: titleColor,
                bodyColor: bodyColor,
              ),
              Divider(height: 24, color: Theme.of(context).dividerColor),
              _SourceRow(
                sourceName: l10n.appInfoNoaa,
                description: l10n.appInfoNoaaDescription,
                titleColor: titleColor,
                bodyColor: bodyColor,
              ),
              Divider(height: 24, color: Theme.of(context).dividerColor),
              _SourceRow(
                sourceName: l10n.appInfoAirNow,
                description: l10n.appInfoAirNowDescription,
                titleColor: titleColor,
                bodyColor: bodyColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            l10n.appInfoDataSourceNotice,
            style: TextStyle(color: bodyColor, fontSize: 11, height: 1.5),
          ),
        ),
      ],
    );
  }
}

/// 로고 없는 출처 행 (OpenWeather, Nominatim 등 외부 서비스용)
class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.sourceName,
    required this.description,
    required this.titleColor,
    required this.bodyColor,
  });

  final String sourceName;
  final String description;
  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sourceName,
          style: TextStyle(
            color: titleColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(color: bodyColor, fontSize: 12),
        ),
      ],
    );
  }
}

class _SourceRowWithLogo extends StatelessWidget {
  const _SourceRowWithLogo({
    required this.sourceName,
    required this.description,
    required this.logoAsset,
    required this.titleColor,
    required this.bodyColor,
  });

  final String sourceName;
  final String description;
  final String logoAsset;
  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sourceName,
          style: TextStyle(
            color: titleColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(color: bodyColor, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Image.asset(
          logoAsset,
          height: 28,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.description,
    this.onTap,
    this.trailingIcon = Icons.open_in_new_rounded,
  });

  final String title;
  final String description;
  final VoidCallback? onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.title(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.body(brightness),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(trailingIcon, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
