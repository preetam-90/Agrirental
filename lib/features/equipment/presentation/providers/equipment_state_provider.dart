import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/location_helper.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/usecases/create_equipment.dart';
import '../../domain/usecases/get_my_equipment.dart';
import '../../domain/usecases/search_equipment_nearby.dart';
import 'equipment_providers.dart';

/// Equipment search state
class EquipmentSearchState {
  final List<Equipment> equipment;
  final bool isLoading;
  final String? errorMessage;
  final Position? currentLocation;
  
  // Search filters
  final EquipmentType? selectedType;
  final double? minRating;
  final double? maxHourlyRate;
  
  const EquipmentSearchState({
    this.equipment = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentLocation,
    this.selectedType,
    this.minRating,
    this.maxHourlyRate,
  });
  
  EquipmentSearchState copyWith({
    List<Equipment>? equipment,
    bool? isLoading,
    String? errorMessage,
    Position? currentLocation,
    EquipmentType? selectedType,
    double? minRating,
    double? maxHourlyRate,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return EquipmentSearchState(
      equipment: equipment ?? this.equipment,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentLocation: currentLocation ?? this.currentLocation,
      selectedType: clearFilters ? null : (selectedType ?? this.selectedType),
      minRating: clearFilters ? null : (minRating ?? this.minRating),
      maxHourlyRate: clearFilters ? null : (maxHourlyRate ?? this.maxHourlyRate),
    );
  }
}

/// Equipment search notifier
class EquipmentSearchNotifier extends StateNotifier<EquipmentSearchState> {
  final SearchEquipmentNearby searchUseCase;
  
  EquipmentSearchNotifier({
    required this.searchUseCase,
  }) : super(const EquipmentSearchState());
  
  /// Search equipment based on current location and filters
  Future<void> searchEquipment() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // Get current location
      final position = await LocationHelper.getCurrentLocation();
      
      state = state.copyWith(currentLocation: position);
      
      // Execute search
      final result = await searchUseCase(
        SearchEquipmentParams(
          farmerLatitude: position.latitude,
          farmerLongitude: position.longitude,
          equipmentType: state.selectedType,
          minRating: state.minRating,
          maxHourlyRate: state.maxHourlyRate,
        ),
      );
      
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          );
        },
        (equipment) {
          state = state.copyWith(
            equipment: equipment,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get location: ${e.toString()}',
      );
    }
  }
  
  /// Update filters and optionally search
  void updateFilters({
    EquipmentType? equipmentType,
    double? minRating,
    double? maxHourlyRate,
    bool autoSearch = false,
  }) {
    state = state.copyWith(
      selectedType: equipmentType,
      minRating: minRating,
      maxHourlyRate: maxHourlyRate,
    );
    
    if (autoSearch && state.currentLocation != null) {
      searchEquipment();
    }
  }
  
  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(clearFilters: true);
  }
  
  /// Map failure to user message
  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection';
    } else if (failure is LocationPermissionDeniedFailure) {
      return 'Location permission denied. Please enable location access.';
    } else if (failure is ServerFailure) {
      return failure.message;
    } else {
      return 'An error occurred while searching';
    }
  }
}

/// My equipment state (for providers)
class MyEquipmentState {
  final List<Equipment> equipment;
  final bool isLoading;
  final String? errorMessage;
  
  const MyEquipmentState({
    this.equipment = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  
  MyEquipmentState copyWith({
    List<Equipment>? equipment,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyEquipmentState(
      equipment: equipment ?? this.equipment,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// My equipment notifier
class MyEquipmentNotifier extends StateNotifier<MyEquipmentState> {
  final GetMyEquipment getMyEquipmentUseCase;
  final CreateEquipment createEquipmentUseCase;
  
  MyEquipmentNotifier({
    required this.getMyEquipmentUseCase,
    required this.createEquipmentUseCase,
  }) : super(const MyEquipmentState());
  
  /// Load user's equipment
  Future<void> loadMyEquipment() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await getMyEquipmentUseCase(const NoParams());
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load equipment',
        );
      },
      (equipment) {
        state = state.copyWith(
          equipment: equipment,
          isLoading: false,
        );
      },
    );
  }
  
  /// Create new equipment
  Future<bool> createEquipment(CreateEquipmentParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await createEquipmentUseCase(params);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create equipment',
        );
        return false;
      },
      (equipment) {
        // Add to list
        final updatedList = [equipment, ...state.equipment];
        state = state.copyWith(
          equipment: updatedList,
          isLoading: false,
        );
        return true;
      },
    );
  }
}

// ============================================================================
// State Providers
// ============================================================================

/// Equipment search state provider
final equipmentSearchNotifierProvider = 
    StateNotifierProvider<EquipmentSearchNotifier, EquipmentSearchState>((ref) {
  return EquipmentSearchNotifier(
    searchUseCase: ref.watch(searchEquipmentNearbyUseCaseProvider),
  );
});

/// My equipment state provider
final myEquipmentNotifierProvider = 
    StateNotifierProvider<MyEquipmentNotifier, MyEquipmentState>((ref) {
  return MyEquipmentNotifier(
    getMyEquipmentUseCase: ref.watch(getMyEquipmentUseCaseProvider),
    createEquipmentUseCase: ref.watch(createEquipmentUseCaseProvider),
  );
});
