import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddListingPage extends ConsumerStatefulWidget {
  const AddListingPage({super.key});

  @override
  ConsumerState<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends ConsumerState<AddListingPage> {
  int _currentStep = 0;
  bool _isEquipment = true;

  // Equipment Form State
  String? _selectedCategory;
  final List<XFile> _images = [];
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();

  // Labour Form State
  final List<String> _selectedSkills = [];
  double _serviceRadius = 25.0;

  final List<String> _equipmentCategories = [
    'Tractor',
    'Harvester',
    'Rotavator',
    'Plough',
    'Seeder',
    'Sprayer',
  ];

  final List<String> _labourSkills = [
    'Tractor Operator',
    'Harvesting',
    'Manual Labour',
    'Seed Planting',
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  void _submitListing() {
    // TODO: Implement submission logic to Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing submitted successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Listing'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submitListing();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Type'),
      isActive: _currentStep >= 0,
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Equipment'),
                  selected: _isEquipment,
                  onSelected: (val) => setState(() => _isEquipment = true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Labour'),
                  selected: !_isEquipment,
                  onSelected: (val) => setState(() => _isEquipment = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isEquipment) ...[
            const Text('Select Equipment Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _equipmentCategories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),
          ] else ...[
            const Text('Select Your Skills'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _labourSkills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Details'),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          if (_isEquipment) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Machine Name (e.g. John Deere 5050)'),
            ),
            const SizedBox(height: 16),
            const Text('Machine Photos'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._images.map((img) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(img.path), width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      )),
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text('Service Radius'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _serviceRadius,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: '${_serviceRadius.round()} km',
                    onChanged: (val) => setState(() => _serviceRadius = val),
                  ),
                ),
                Text('${_serviceRadius.round()} km'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Pricing'),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _isEquipment ? 'Hourly Rate (₹)' : 'Daily Rate (₹)',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description (Optional)'),
          ),
        ],
      ),
    );
  }
}
