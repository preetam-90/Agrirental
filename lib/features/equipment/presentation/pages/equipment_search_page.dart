import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/equipment.dart';
import '../providers/equipment_state_provider.dart';
import '../widgets/equipment_card.dart';
import '../widgets/equipment_filters_sheet.dart';

/// Equipment search page for farmers
class EquipmentSearchPage extends ConsumerStatefulWidget {
  const EquipmentSearchPage({super.key});

  @override
  ConsumerState<EquipmentSearchPage> createState() => _EquipmentSearchPageState();
}

class _EquipmentSearchPageState extends ConsumerState<EquipmentSearchPage> {
  @override
  void initState() {
    super.initState();
    // Trigger initial search on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(equipmentSearchNotifierProvider.notifier).searchEquipment();
    });
  }
  
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const EquipmentFiltersSheet(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(equipmentSearchNotifierProvider);
    final theme = Theme.of(context);
    
    const languageCode = 'en';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('search_equipment', languageCode)),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: searchState.selectedType != null || 
                            searchState.minRating != null || 
                            searchState.maxHourlyRate != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilters,
            tooltip: AppStrings.get('filters', languageCode),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(equipmentSearchNotifierProvider.notifier).searchEquipment();
        },
        child: _buildBody(searchState, theme, languageCode),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(equipmentSearchNotifierProvider.notifier).searchEquipment();
        },
        icon: const Icon(Icons.search),
        label: Text(AppStrings.get('search', languageCode)),
      ),
    );
  }
  
  Widget _buildBody(EquipmentSearchState state, ThemeData theme, String languageCode) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(equipmentSearchNotifierProvider.notifier).searchEquipment();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state.equipment.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('no_results_found', languageCode),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or search again',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.equipment.length,
      itemBuilder: (context, index) {
        final equipment = state.equipment[index];
        return EquipmentCard(
          equipment: equipment,
          onTap: () {
            // Navigate to details page
            // Navigator.push(context, EquipmentDetailsPage(equipment: equipment));
          },
        );
      },
    );
  }
}
