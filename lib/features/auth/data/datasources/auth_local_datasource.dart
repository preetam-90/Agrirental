import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Local data source for caching user data with Hive
abstract class AuthLocalDataSource {
  /// Cache user profile locally
  Future<void> cacheUser(UserModel user);
  
  /// Get cached user profile
  Future<UserModel> getCachedUser();
  
  /// Clear cached user data
  Future<void> clearCache();
  
  /// Check if user is cached
  Future<bool> hasCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box userBox;
  
  AuthLocalDataSourceImpl({required this.userBox});
  
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      // Store in Hive box
      await userBox.put(AppConstants.userProfileKey, userJson);
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> getCachedUser() async {
    try {
      final userJson = userBox.get(AppConstants.userProfileKey);
      
      if (userJson == null) {
        throw CacheException('No cached user found');
      }
      
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final Map<String, dynamic> userData = Map<String, dynamic>.from(userJson as Map);
      
      return UserModel.fromJson(userData);
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearCache() async {
    try {
      await userBox.delete(AppConstants.userProfileKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> hasCachedUser() async {
    try {
      return userBox.containsKey(AppConstants.userProfileKey);
    } catch (e) {
      return false;
    }
  }
}
