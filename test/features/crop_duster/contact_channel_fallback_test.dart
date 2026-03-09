import 'package:crop_id/core/constants/app_constants.dart';
import 'package:crop_id/features/crop_duster/data/models/crop_duster_service.dart';
import 'package:crop_id/features/crop_duster/presentation/screens/crop_duster_screen.dart';
import 'package:crop_id/features/crop_duster/providers/crop_duster_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows fallback when selected service has no contact channels',
      (tester) async {
    const payload = CropDusterContactPayload(
      fieldName: 'South Hippy Hollow',
      chemicalNames: ['Malathion'],
      dangerCount: 1,
    );
    const service = CropDusterService(
      id: 'svc-2',
      name: 'No Channel Air',
      phone: '',
      email: null,
      isActive: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactPayloadProvider.overrideWith((_) => payload),
          cropDusterSearchResultsProvider.overrideWith((_) async => [service]),
        ],
        child: const MaterialApp(home: CropDusterScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Send Info'));
    await tester.pump();

    expect(
      find.text(AppConstants.contactStateUnavailableLabel),
      findsOneWidget,
    );
  });
}
