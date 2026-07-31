import 'package:crop_id/features/crop_duster/data/models/crop_duster_service.dart';
import 'package:crop_id/features/crop_duster/presentation/screens/crop_duster_screen.dart';
import 'package:crop_id/features/crop_duster/providers/crop_duster_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('service types round-trip through Supabase JSON values', () {
    final service = CropDusterService.fromJson({
      'id': 'service-1',
      'name': 'Prairie Drone Applications',
      'phone': '555-0100',
      'service_type': 'drone',
    });

    expect(service.serviceType, SprayingServiceType.drone);
    expect(service.toJson()['service_type'], 'drone');
  });

  testWidgets('service selector offers all supported spraying types',
      (tester) async {
    const services = [
      CropDusterService(
        id: 'drone-1',
        name: 'Prairie Drone Applications',
        phone: '555-0101',
        serviceType: SprayingServiceType.drone,
      ),
      CropDusterService(
        id: 'air-1',
        name: 'Delta AgAir Services',
        phone: '555-0102',
        serviceType: SprayingServiceType.agAir,
      ),
      CropDusterService(
        id: 'coop-1',
        name: 'County Line Co-op Agronomy',
        phone: '555-0103',
        serviceType: SprayingServiceType.coOp,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cropDusterSearchResultsProvider.overrideWith((_) async => services),
          contactPayloadProvider.overrideWith((_) => null),
        ],
        child: const MaterialApp(home: CropDusterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsNWidgets(4));
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(
      find.widgetWithText(ChoiceChip, 'Drone Spraying'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ChoiceChip, 'Ag Air'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Co-op'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Drone Spraying'));
    await tester.pump();

    final context = tester.element(find.byType(CropDusterScreen));
    final container = ProviderScope.containerOf(context);
    expect(
      container.read(selectedSprayingServiceTypeProvider),
      SprayingServiceType.drone,
    );
  });
}
