import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/utils/color_utils.dart';
import '../models/account_model.dart';
import '../models/payment_provider.dart';

/// Renders an official Kenyan bank/wallet SVG or raster logo badge when matched,
/// or a clean branded fallback badge using [colorHex] and [type].
class AccountBrandBadge extends StatelessWidget {
  final String? icon;
  final String name;
  final String type;
  final String colorHex;
  final double size;
  final double? borderRadius;

  const AccountBrandBadge({
    super.key,
    this.icon,
    required this.name,
    required this.type,
    required this.colorHex,
    this.size = 44,
    this.borderRadius,
  });

  factory AccountBrandBadge.fromAccount(
    AccountWithBalance account, {
    Key? key,
    double size = 44,
    double? borderRadius,
  }) =>
      AccountBrandBadge(
        key: key,
        icon: account.icon,
        name: account.name,
        type: account.type,
        colorHex: account.colorHex,
        size: size,
        borderRadius: borderRadius,
      );

  factory AccountBrandBadge.fromProvider(
    PaymentProvider provider, {
    Key? key,
    double size = 44,
    double? borderRadius,
  }) =>
      AccountBrandBadge(
        key: key,
        icon: provider.id,
        name: provider.name,
        type: provider.type,
        colorHex: provider.primaryColorHex,
        size: size,
        borderRadius: borderRadius,
      );

  static IconData _fallbackIconForType(String type) => switch (type) {
        'bank' => Icons.account_balance_rounded,
        'cash' => Icons.payments_rounded,
        'mpesa' || 'airtel' || 'mobile' => Icons.phone_android_rounded,
        _ => Icons.account_balance_wallet_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.25);
    final provider = PaymentProviders.resolve(
      icon: icon,
      name: name,
      type: type,
    );

    if (provider != null) {
      final innerSize = provider.fullBleedBadge ? size : size * 0.8;
      final fit = provider.fullBleedBadge ? BoxFit.cover : BoxFit.contain;
      final logoWidget = provider.isSvg
          ? SvgPicture.asset(
              provider.logoAsset,
              width: innerSize,
              height: innerSize,
              fit: fit,
            )
          : Image.asset(
              provider.logoAsset,
              width: innerSize,
              height: innerSize,
              fit: fit,
              filterQuality: FilterQuality.medium,
            );

      if (provider.fullBleedBadge) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: logoWidget,
        );
      }

      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        padding: EdgeInsets.all(size * 0.1),
        child: Center(child: logoWidget),
      );
    }

    final bgColor = parseHexColor(
      colorHex,
      fallback: Theme.of(context).colorScheme.primary,
    );
    final fgColor =
        bgColor.computeLuminance() > 0.55 ? Colors.black87 : Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(
          _fallbackIconForType(type),
          color: fgColor,
          size: size * 0.54,
        ),
      ),
    );
  }
}

/// Returns a readable 2-stop gradient for account cards so white text always
/// has high contrast regardless of brand or custom color.
List<Color> accountCardGradientColors(AccountWithBalance account) {
  final provider = PaymentProviders.resolve(
    icon: account.icon,
    name: account.name,
    type: account.type,
  );
  if (provider != null) {
    return [
      parseHexColor(provider.primaryColorHex),
      parseHexColor(provider.secondaryColorHex),
    ];
  }

  var base = parseHexColor(account.colorHex, fallback: const Color(0xFF1B5E20));
  if (base.computeLuminance() > 0.48) {
    base = Color.lerp(base, Colors.black, 0.35)!;
  }
  return [
    base,
    Color.lerp(base, Colors.black, 0.32)!,
  ];
}
