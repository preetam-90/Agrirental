import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Authentication repository implementation
/// Handles offline-first caching and network connectivity
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, void>> sendOTP(String phoneNumber) async {
    // Check network connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }
    
    try {
      await remoteDataSource.sendOTP(phoneNumber);
      return const Right(null);
    } on AuthException catch (e) {
      if (e.code == '401' || e.code == 'invalid_otp') {
        return const Left(InvalidOTPFailure());
      }
      return Left(AuthFailure(e.message, e.code));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    // Check network connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }
    
    try {
      final userModel = await remoteDataSource.verifyOTP(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      
      // Cache user for offline access
      await localDataSource.cacheUser(userModel);
      
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      if (e.code == '401' || e.message.toLowerCase().contains('invalid')) {
        return const Left(InvalidOTPFailure());
      }
      return Left(AuthFailure(e.message, e.code));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> signInWithGoogle() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.signInWithGoogle();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // First try to get from remote (if connected)
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        try {
          final userModel = await remoteDataSource.getCurrentUser();
          // Update cache
          await localDataSource.cacheUser(userModel);
          return Right(userModel.toEntity());
        } on AuthException catch (e) {
          // If unauthorized, try cache
          if (e.code == '401') {
            return _getUserFromCache();
          }
          return Left(AuthFailure(e.message, e.code));
        } on ServerException {
          // If server error, fallback to cache
          return _getUserFromCache();
        }
      }
      
      // No connection - use cached data
      return _getUserFromCache();
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  /// Helper method to get user from cache
  Future<Either<Failure, User>> _getUserFromCache() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser.toEntity());
    } on CacheException {
      return const Left(UnauthorizedFailure());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Sign out from Supabase
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.signOut();
      }
      
      // Always clear local cache
      await localDataSource.clearCache();
      
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    required String addressText,
    required double latitude,
    required double longitude,
  }) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.updateProfile(
        fullName: fullName,
        addressText: addressText,
        latitude: latitude,
        longitude: longitude,
      );
      
      // Update cache after successful profile update
      final updatedUser = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(updatedUser);
      
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileRole(UserRole role) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.updateProfileRole(role);
      
      // Update cache
      final updatedUser = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(updatedUser);
      
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<bool> isAuthenticated() async {
    try {
      // Check remote session if connected
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        return await remoteDataSource.isAuthenticated();
      }
      
      // Check local cache
      return await localDataSource.hasCachedUser();
    } catch (e) {
      return false;
    }
  }
}
