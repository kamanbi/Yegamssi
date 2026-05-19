import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/version/app_update_service.dart';
import '../../../core/widgets/premium_card.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  static const String _homepage = 'https://yegamssi.netlify.app/';
  static const String _privacyPolicy = 'https://yegamssi.netlify.app/privacy';
  static const String _email = 'kamanbi23@naver.com';
  static const double _bottomClearance = 152;
  static const double _qrSize = 236;

  @override
  Widget build(BuildContext context) {
    final versionFuture = PackageInfo.fromPlatform();
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('앱 정보'),
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          const _InfoLinkCard(),
          const SizedBox(height: AppSpacing.x3),
          const _DataSourceSection(),
          const SizedBox(height: AppSpacing.x3),
          _VersionCard(brightness: brightness, versionFuture: versionFuture),
          const SizedBox(height: _bottomClearance),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('스토어 링크를 복사했습니다.')));
  }

  static Future<void> _openStore(BuildContext context) async {
    final launched = await _launchUrl(AppUpdateService.defaultPlayStoreUrl);
    if (launched || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('스토어 링크를 복사했습니다.')));
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
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            title: '홈페이지',
            description: '예감씨 소개 페이지를 엽니다.',
            onTap: () => AppInfoScreen._launchUrl(AppInfoScreen._homepage),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: '개인정보 처리방침',
            description: '개인정보 처리방침 페이지를 엽니다.',
            onTap: () => AppInfoScreen._launchUrl(AppInfoScreen._privacyPolicy),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: '문의 이메일',
            description: '문의 메일 앱을 엽니다.',
            onTap: () =>
                AppInfoScreen._launchUrl('mailto:${AppInfoScreen._email}'),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: '예감씨 공유하기',
            description: '스토어로 연결되는 QR 코드를 보여줍니다.',
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
              '예감씨 공유하기',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.title(brightness),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QR 코드를 스캔하면 예감씨 스토어 페이지로 이동합니다.',
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
                    child: const Text('링크 복사'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => AppInfoScreen._openStore(context),
                    child: const Text('스토어 열기'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.brightness, required this.versionFuture});

  final Brightness brightness;
  final Future<PackageInfo> versionFuture;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: FutureBuilder<PackageInfo>(
        future: versionFuture,
        builder: (context, snapshot) {
          final versionText = snapshot.hasData
              ? '현재 버전 ${snapshot.data!.version}+${snapshot.data!.buildNumber}'
              : '버전 확인 중...';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '앱 버전',
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
    final titleColor = AppColors.title(brightness);
    final bodyColor = AppColors.body(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '데이터 출처',
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
                icon: Icons.cloud_outlined,
                iconColor: const Color(0xFF64B5F6),
                sourceName: '기상청',
                description: '날씨와 예보 데이터를 제공합니다.',
                logoAsset: 'assets/images/kogl_type0_ko.png',
                bodyColor: bodyColor,
              ),
              const Divider(height: 24, color: Colors.white12),
              _SourceRowWithLogo(
                icon: Icons.masks_rounded,
                iconColor: const Color(0xFFCE93D8),
                sourceName: '에어코리아',
                description: '미세먼지, 초미세먼지, 오존, 통합 대기질 정보를 제공합니다.',
                logoAsset: 'assets/images/kogl_type3.png',
                bodyColor: bodyColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '일부 정보는 공공데이터포털과 공공누리 출처 표시 기준을 따릅니다.',
            style: TextStyle(color: bodyColor, fontSize: 11, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _SourceRowWithLogo extends StatelessWidget {
  const _SourceRowWithLogo({
    required this.icon,
    required this.iconColor,
    required this.sourceName,
    required this.description,
    required this.logoAsset,
    required this.bodyColor,
  });

  final IconData icon;
  final Color iconColor;
  final String sourceName;
  final String description;
  final String logoAsset;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sourceName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
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
          ),
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
