import 'package:crop_id/features/auth/providers/auth_provider.dart';
import 'package:crop_id/features/crop_duster/data/models/crop_duster_service.dart';
import 'package:crop_id/features/crop_duster/presentation/screens/contact_screen.dart';
import 'package:crop_id/features/crop_duster/providers/crop_duster_provider.dart';
import 'package:crop_id/features/spray_planning/providers/spray_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/farmer_test_fixtures.dart';

void main() {
  testWidgets('message preview is prefilled from saved plan payload',
      (tester) async {
    const payload = CropDusterContactPayload(
      fieldName: 'South Hippy Hollow',
      chemicalNames: ['Malathion', 'Paraquat'],
      dangerCount: 3,
      lat: 36.3,
      lng: -93.76,
      sourcePlanId: 'plan-42',
    );
    const service = CropDusterService(
      id: 'svc-1',
      name: 'Midwest AirSpray LLC',
      phone: '555-0102',
      email: 'dispatch@midwest.example',
      address: '100 Airfield Rd',
      serviceRadiusMiles: 150,
      isActive: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedServiceProvider.overrideWith((_) => service),
          contactPayloadProvider.overrideWith((_) => payload),
          selectedChemicalsProvider.overrideWith((_) => const []),
          farmerProfileProvider
              .overrideWith((_) async => FarmerTestFixtures.farmerProfile()),
        ],
        child: const MaterialApp(home: ContactScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Contact Midwest AirSpray LLC'), findsOneWidget);
    expect(
      find.textContaining('South Hippy Hollow'),
      findsWidgets,
    );
    expect(
      find.textContaining('Chemicals: Malathion, Paraquat'),
      findsOneWidget,
    );
    expect(
      find.textContaining('WARNING: 3 neighboring field(s) may be at risk.'),
      findsOneWidget,
    );
  });
}
