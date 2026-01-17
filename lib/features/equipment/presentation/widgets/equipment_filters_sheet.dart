import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/equipment.dart';
import '../providers/equipment_state_provider.dart';

/// Bottom sheet for equipment search filters
class EquipmentFiltersSheet extends ConsumerStatefulWidget {
  const EquipmentFiltersSheet({super.key});

  @override
  ConsumerState<EquipmentFiltersSheet> createState() => _EquipmentFiltersSheetState();
}

class _EquipmentFiltersSheetState extends ConsumerState<EquipmentFiltersSheet> {
  EquipmentType? _selectedType;
  double? _minRating;
  double? _maxHourlyRate;
  
  @override
  void initState() {
    super.initState();
    // Initialize with current filters
    final currentState = ref.read(equipmentSearchNotifierProvider);
    _selectedType = currentState.selectedType;
    _minRating = currentState.minRating;
    _maxHourlyRate = currentState.maxHourlyRate;
  }
  
  void _applyFilters() {
    ref.read(equipmentSearchNotifierProvider.notifier).updateFilters(
      equipmentType: _selectedType,
      minRating: _minRating,
      maxHourlyRate: _maxHourlyRate,
      autoSearch: true,
    );
    Navigator.pop(context);
  }
  
  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _minRating = null;
      _maxHourlyRate = null;
    });
    ref.read(equipmentSearchNotifierProvider.notifier).clearFilters();
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const languageCode = 'en';
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.get('filters', languageCode),
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(AppStrings.get('clear_filters', languageCode)),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Equipment Type Filter
            Text(
              AppStrings.get('equipment_type', languageCode),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EquipmentType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Rating Filter
            Text(
              AppStrings.get('rating', languageCode),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Slider(
              value: _minRating ?? 0,
              min: 0,
              max: 5,
              divisions: 10,
              label: _minRating != null ? '${_minRating!.toStringAsFixed(1)}+ stars' : 'Any',
              onChanged: (value) {
                setState(() {
                  _minRating = value > 0 ? value : null;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Max Hourly Rate Filter
            Text(
              'Max Hourly Rate',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Slider(
              value: _maxHourlyRate ?? 5000,
              min: 0,
              max: 5000,
              divisions: 50,
              label: _maxHourlyRate != null ? '₹${_maxHourlyRate!.toStringAsFixed(0)}' : 'Any',
              onChanged: (value) {
                setState(() {
                  _maxHourlyRate = value > 0 ? value : null;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Apply Button
            ElevatedButton(
              onPressed: _applyFilters,
              child: Text(AppStrings.get('apply_filters', languageCode)),
            ),
          ],
        ),
      ),
    );
  }
}
