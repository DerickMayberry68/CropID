import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../shared/services/supabase_service.dart';
import 'models/crop_duster_service.dart';

class CropDusterRepository {
  final SupabaseClient _client;
  CropDusterRepository(this._client);

  Future<Either<String, List<CropDusterService>>> getNearbyServices({
    required double lat,
    required double lng,
    SprayingServiceType? serviceType,
    double radiusDeg = 2.0, // ~200km rough bounding box
  }) async {
    try {
      // TODO: Phase 4 — Replace with PostGIS ST_DWithin RPC for true geo-radius
      var request = _client
          .from(SupabaseConstants.cropDusterServicesTable)
          .select()
          .eq('is_active', true);
      if (serviceType != null) {
        request = request.eq('service_type', serviceType.databaseValue);
      }
      final data = await request.order('name');
      return Right(
          (data as List).map((e) => CropDusterService.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<CropDusterService>>> searchServices(
    String query, {
    SprayingServiceType? serviceType,
  }) async {
    try {
      var request = _client
          .from(SupabaseConstants.cropDusterServicesTable)
          .select()
          .or('name.ilike.%$query%,state.ilike.%$query%')
          .eq('is_active', true);
      if (serviceType != null) {
        request = request.eq('service_type', serviceType.databaseValue);
      }
      final data = await request.order('name').limit(20);
      return Right(
          (data as List).map((e) => CropDusterService.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> contactService({
    required String serviceId,
    required String farmerId,
    required String fieldName,
    required List<String> chemicalNames,
    required int dangerCount,
    required String message,
    double? lat,
    double? lng,
    bool sendSms = true,
    bool sendEmail = false,
    String? servicePhone,
    String? serviceEmail,
  }) async {
    final validationError = _validateContactPayload(
      serviceId: serviceId,
      farmerId: farmerId,
      fieldName: fieldName,
      message: message,
      sendSms: sendSms,
      sendEmail: sendEmail,
      servicePhone: servicePhone,
      serviceEmail: serviceEmail,
    );
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      final response = await SupabaseService.invokeAuthedFunction(
        SupabaseConstants.contactCropDusterFunction,
        body: {
          'service_id': serviceId,
          'farmer_id': farmerId,
          'field_name': fieldName,
          'chemical_names': chemicalNames,
          'danger_count': dangerCount,
          'message': message,
          'send_sms': sendSms,
          'send_email': sendEmail,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );

      if (response.status >= 400) {
        final data = response.data;
        if (data is Map && data['error'] != null) {
          return Left(data['error'].toString());
        }
        return Left('Contact service failed with status ${response.status}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) return Right(data);
      if (data is Map) return Right(Map<String, dynamic>.from(data));

      return const Left('Unexpected response from contact service');
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  String? _validateContactPayload({
    required String serviceId,
    required String farmerId,
    required String fieldName,
    required String message,
    required bool sendSms,
    required bool sendEmail,
    required String? servicePhone,
    required String? serviceEmail,
  }) {
    if (serviceId.trim().isEmpty) return 'Missing service context.';
    if (farmerId.trim().isEmpty) return 'Missing farmer context.';
    if (fieldName.trim().isEmpty) return 'Missing field context.';
    if (message.trim().isEmpty) return 'Missing contact message.';
    if (!sendSms && !sendEmail) {
      return 'Choose at least one contact method.';
    }
    if (sendSms && (servicePhone ?? '').trim().isEmpty) {
      return 'Selected service cannot receive SMS.';
    }
    if (sendEmail && (serviceEmail ?? '').trim().isEmpty) {
      return 'Selected service cannot receive email.';
    }
    return null;
  }
}
