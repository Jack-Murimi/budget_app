import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared motion language: one set of durations & curves so every screen
/// moves with the same personality.
abstract final class Motion {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 600);
  static const stagger = Duration(milliseconds: 55);

  /// Material 3 "emphasized" feel.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// Fades + slides its child up on first build. Stagger lists by passing the
/// item [index]. Implemented with a single tween (no timers) so it is safe in
/// widget tests and respects the system "remove animations" setting.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  final double dy;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.dy = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    final delayMs = (index.clamp(0, 10)) * Motion.stagger.inMilliseconds;
    final totalMs = Motion.slow.inMilliseconds + delayMs;
    final start = delayMs / totalMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(start, 1, curve: Motion.emphasizedDecelerate),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child:
            Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
      ),
    );
  }
}

/// Tactile press feedback: scales down slightly while pressed.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = false,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: (_down && !reduced) ? widget.scale : 1,
        duration: reduced ? Duration.zero : Motion.fast,
        curve: Motion.emphasized,
        child: widget.child,
      ),
    );
  }
}

/// Counts smoothly from the previous value to [value] whenever it changes.
class AnimatedAmount extends StatelessWidget {
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedAmount({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final textStyle = base.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    if (Motion.reduced(context)) {
      return Text(
        format(value),
        style: textStyle,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: Motion.slow + const Duration(milliseconds: 300),
      curve: Motion.emphasizedDecelerate,
      builder: (_, v, __) => Text(
        format(v),
        style: textStyle,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Smoothly animates a rounded linear progress bar to [value] (0..1).
/// Timer-free and respects [Motion.reduced].
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double minHeight;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.minHeight = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clamped = value.clamp(0.0, 1.0);
    final barColor = color ?? cs.primary;
    final trackColor = backgroundColor ?? cs.surfaceContainerHighest;
    final radius = borderRadius ?? BorderRadius.circular(minHeight);

    Widget buildBar(double v) => ClipRRect(
          borderRadius: radius,
          child: LinearProgressIndicator(
            value: v,
            minHeight: minHeight,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        );

    if (Motion.reduced(context)) return buildBar(clamped);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: clamped),
      duration: Motion.slow + const Duration(milliseconds: 250),
      curve: Motion.emphasizedDecelerate,
      builder: (_, v, __) => buildBar(v),
    );
  }
}
