import 'package:budget_app/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FadeSlideIn animates cleanly and settles with no pending timers',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FadeSlideIn(
            index: 2,
            child: Text('Hello Motion'),
          ),
        ),
      ),
    );

    expect(find.text('Hello Motion'), findsOneWidget);
    await tester.pumpAndSettle();

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1.0);
  });

  testWidgets('FadeSlideIn bypasses animation when disableAnimations is true',
      (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(
            body: FadeSlideIn(
              index: 3,
              child: Text('Instant'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Instant'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('Pressable invokes onTap and scales during press', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Pressable(
            scale: 0.95,
            onTap: () => tapped = true,
            child: const SizedBox(
              width: 120,
              height: 48,
              child: Center(child: Text('Tap Me')),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('Tap Me')));
    await tester.pump();
    final pressedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(pressedScale.scale, 0.95);

    await gesture.up();
    await tester.pumpAndSettle();
    final releasedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(releasedScale.scale, 1.0);
    expect(tapped, isTrue);
  });

  testWidgets('AnimatedAmount counts up to target value with tabular figures',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedAmount(
            value: 12500.5,
            format: (v) => 'KES ${v.toStringAsFixed(2)}',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('KES 12500.50'), findsOneWidget);
    final textWidget = tester.widget<Text>(find.text('KES 12500.50'));
    expect(
      textWidget.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('AnimatedAmount respects reduced motion immediately', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(
            body: AnimatedAmount(
              value: 4200,
              format: (v) => 'KES ${v.toStringAsFixed(0)}',
            ),
          ),
        ),
      ),
    );

    expect(find.text('KES 4200'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('AnimatedProgressBar clamps value and settles cleanly',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedProgressBar(value: 1.4),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 1.0);
  });
}
