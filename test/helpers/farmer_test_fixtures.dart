import 'package:crop_id/features/auth/data/models/farmer_profile.dart';
import 'package:crop_id/features/farm_map/data/models/field.dart';
import 'package:crop_id/features/spray_planning/data/models/chemical.dart';
import 'package:crop_id/features/spray_planning/data/models/spray_plan.dart';

class FarmerTestFixtures {
  static FarmerProfile farmerProfile({
    String id = 'farmer-1',
    String email = 'farmer1@example.com',
    String fullName = 'Test Farmer',
  }) {
    return FarmerProfile(
      id: id,
      email: email,
      fullName: fullName,
      farmName: 'North Field Farm',
      phoneNumber: '555-0100',
    );
  }

  static Field field({
    String id = 'field-1',
    String farmerId = 'farmer-1',
    String name = 'North 40',
    String? cropId = 'crop-corn',
  }) {
    return Field(
      id: id,
      farmerId: farmerId,
      name: name,
      currentCropId: cropId,
      currentCropName: 'Corn',
      boundaryPoints: const [
        {'lat': 41.0000, 'lng': -93.0000},
        {'lat': 41.0005, 'lng': -93.0000},
        {'lat': 41.0005, 'lng': -93.0005},
        {'lat': 41.0000, 'lng': -93.0005},
      ],
    );
  }

  static Chemical chemical({
    String id = 'chem-1',
    String name = 'Atrazine',
    List<String> dangerousToCropIds = const ['crop-soybean'],
  }) {
    return Chemical(
      id: id,
      name: name,
      commonName: name,
      dangerousToCropIds: dangerousToCropIds,
      dangerousToCropNames: const ['Soybean'],
    );
  }

  static SprayPlan sprayPlan({
    String id = 'plan-1',
    String farmerId = 'farmer-1',
    String fieldId = 'field-1',
    String fieldName = 'North 40',
    List<Chemical> chemicals = const [],
    List<String> dangerousAdjacentFieldIds = const [],
  }) {
    return SprayPlan(
      id: id,
      farmerId: farmerId,
      fieldId: fieldId,
      fieldName: fieldName,
      chemicals: chemicals,
      dangerousAdjacentFieldIds: dangerousAdjacentFieldIds,
      createdAt: DateTime.parse('2026-03-07T12:00:00Z'),
    );
  }
}
