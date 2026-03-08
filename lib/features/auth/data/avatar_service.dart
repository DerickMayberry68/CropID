import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

/// Handles avatar image picking, uploading to Supabase Storage,
/// and updating the profile avatar_url column.
class AvatarService {
  final SupabaseClient _client;

  AvatarService(this._client);

  static const _bucket = 'avatars';

  /// Opens the image picker and returns the selected [XFile], or null if
  /// the user cancelled.
  Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    return picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
  }

  /// Uploads [image] to Supabase Storage under `{userId}/avatar.jpg`,
  /// then updates the `avatar_url` column on the profiles table.
  /// Returns the public URL on success.
  Future<Either<String, String>> uploadAvatar({
    required String userId,
    required XFile image,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final storagePath = '$userId/avatar.jpg';

      // Upload — upsert:true overwrites any existing avatar
      await _client.storage.from(_bucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get the permanent public URL
      final publicUrl =
          _client.storage.from(_bucket).getPublicUrl(storagePath);

      // Stamp a cache-bust so the UI refreshes even if the path is the same
      final urlWithBust =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // Update profile row
      await _client
          .from('profiles')
          .update({'avatar_url': urlWithBust})
          .eq('id', userId);

      return Right(urlWithBust);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
