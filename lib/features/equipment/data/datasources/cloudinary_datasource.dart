import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Data source for uploading images to Cloudinary
abstract class CloudinaryDataSource {
  /// Upload image file to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage(String imagePath);
  
  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(List<String> imagePaths);
}

class CloudinaryDataSourceImpl implements CloudinaryDataSource {
  final CloudinaryPublic cloudinary;
  
  CloudinaryDataSourceImpl({required this.cloudinary});
  
  @override
  Future<String> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      
      if (!await file.exists()) {
        throw ValidationException('Image file does not exist');
      }
      
      // Upload to Cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          folder: 'agriflutter/equipment',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      throw ServerException('Failed to upload image: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to upload image: ${e.toString()}');
    }
  }
  
  @override
  Future<List<String>> uploadMultipleImages(List<String> imagePaths) async {
    final List<String> uploadedUrls = [];
    
    for (final imagePath in imagePaths) {
      try {
        final url = await uploadImage(imagePath);
        uploadedUrls.add(url);
      } catch (e) {
        // Continue uploading other images even if one fails
        continue;
      }
    }
    
    if (uploadedUrls.isEmpty && imagePaths.isNotEmpty) {
      throw ServerException('Failed to upload any images');
    }
    
    return uploadedUrls;
  }
}

/// Factory for creating Cloudinary instance
class CloudinaryFactory {
  /// Create instance for unsigned uploads (recommended for mobile)
  static CloudinaryPublic createUnsigned() {
    return CloudinaryPublic(
      AppConstants.cloudinaryCloudName,
      AppConstants.cloudinaryUploadPreset,
      cache: false,
    );
  }
}
