import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_state_provider.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isLocating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final latLng = LatLng(position.latitude, position.longitude);
        
        setState(() {
          _selectedLocation = latLng;
        });
        
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your location on the map')),
      );
      return;
    }

    print('DEBUG: Starting profile update...');
    print('DEBUG: Name: ${_nameController.text}');
    print('DEBUG: Address: ${_addressController.text}');
    print('DEBUG: Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}');

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.updateProfile(
      fullName: _nameController.text,
      addressText: _addressController.text,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
    );
    
    print('DEBUG: Update success: $success');
    
    if (success && mounted) {
      print('DEBUG: Profile updated successfully, showing message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // On success, main.dart will handle redirect via isProfileCompleteProvider
    } else if (!success && mounted) {
      print('DEBUG: Profile update failed');
      final authState = ref.read(authNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to AgriServe!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your details to get started.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your address';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Text(
                'Pin Your Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: kIsWeb ? _buildWebLocationPicker() : _buildMapWidget(),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _submitProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save and Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapWidget() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(20.5937, 78.9629), // Center of India
            zoom: 5,
          ),
          onMapCreated: (controller) => _mapController = controller,
          onTap: (latLng) {
            setState(() => _selectedLocation = latLng);
          },
          markers: _selectedLocation == null
              ? {}
              : {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: _selectedLocation!,
                  ),
                },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: _getCurrentLocation,
            child: _isLocating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLocationPicker() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Map Selection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use mobile app for interactive map selection',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_selectedLocation != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Location Selected',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ] else
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isLocating ? 'Getting Location...' : 'Use Current Location'),
            ),
        ],
      ),
    );
  }
}

