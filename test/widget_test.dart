import 'package:crop_id/app.dart';
import 'package:crop_id/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('root app rendering smoke test', (WidgetTester tester) async {
    final smokeRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SizedBox.expand(),
        ),
      ],
    );
    addTearDown(smokeRouter.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWith((_) => smokeRouter),
        ],
        child: const CropIdApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CropIdApp), findsOneWidget);
  });
}
