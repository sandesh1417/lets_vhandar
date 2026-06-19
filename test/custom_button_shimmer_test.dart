import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lets_vhandar/widgets/custom_button.dart';
import 'package:lets_vhandar/widgets/shimmer_button_effect.dart';

Widget _host(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  testWidgets('idle button is tappable and shows the shimmer sweep',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(
      CustomElevatedButton(text: 'Save', onPressed: () => taps++),
    ));
    await tester.pump(); // let ScreenUtilInit build

    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(ShimmerSweepOverlay), findsOneWidget);
    expect(find.byType(LoadingShimmerContent), findsNothing);

    await tester.tap(find.text('Save'));
    expect(taps, 1);
  });

  testWidgets('auto-sized button keeps the default 64x48 minimum',
      (tester) async {
    await tester.pumpWidget(_host(
      CustomElevatedButton(text: 'x', onPressed: () {}),
    ));
    await tester.pump();

    final size = tester.getSize(find.byType(CustomElevatedButton));
    expect(size.width, greaterThanOrEqualTo(64.0));
    expect(size.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('isLoading: shows skeleton + spinner, hides label, blocks taps',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(
      CustomElevatedButton(
        text: 'Submit',
        isLoading: true,
        onPressed: () => taps++,
      ),
    ));
    await tester.pump();

    expect(find.byType(LoadingShimmerContent), findsOneWidget);
    expect(find.byType(ShimmerSweepOverlay), findsNothing);
    // Cupertino spinner present.
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    // Label is kept for sizing but fully transparent.
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Submit'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0.0);

    // Non-tappable while loading (hit test intentionally misses).
    await tester.tap(find.byType(CustomElevatedButton), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('enableShimmer: false disables the idle sweep only',
      (tester) async {
    await tester.pumpWidget(_host(
      CustomElevatedButton(
        text: 'Plain',
        enableShimmer: false,
        onPressed: () {},
      ),
    ));
    await tester.pump();

    expect(find.text('Plain'), findsOneWidget);
    expect(find.byType(ShimmerSweepOverlay), findsNothing);
  });

  testWidgets('press scale: scales down on pointer down, springs back on up',
      (tester) async {
    await tester.pumpWidget(_host(
      CustomElevatedButton(text: 'Press', onPressed: () {}),
    ));
    await tester.pump();

    double currentScale() => tester
        .widget<AnimatedScale>(find.byType(AnimatedScale))
        .scale;

    expect(currentScale(), 1.0);

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Press')));
    await tester.pump(const Duration(milliseconds: 16));
    expect(currentScale(), 0.96); // target scale while pressed

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));
    expect(currentScale(), 1.0); // springs back to rest
    // Note: no pumpAndSettle — the idle shimmer repeats forever by design.
  });
}
