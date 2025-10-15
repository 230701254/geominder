import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geominder/models/location_search_result.dart';
import 'package:geominder/models/reminder_model.dart';
import 'package:geominder/globals/app_state.dart';
import 'package:geominder/location_service.dart'; // IMPORT a
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';

@NowaGenerated()
class AddReminderScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() {
    return _AddReminderScreenState();
  }
}

@NowaGenerated()
class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  // Get an instance of your new service
  final LocationService _locationService = LocationService();

  LocationSearchResult? _selectedLocation;
  List<LocationSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;
  double _radius = 100;
  Timer? _debounce;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      _searchLocations(query);
    });
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);

    try {
      // **REPLACED**: The mock data is gone. We now call the service.
      final results = await _locationService.searchPlaces(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectLocation(LocationSearchResult location) {
    setState(() {
      _selectedLocation = location;
      _locationController.text = location.name;
      _searchResults = [];
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a location'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final appState = AppState.of(context, listen: false);
      final String? userId = appState.userId;

      if (userId == null) {
        throw Exception('User is not logged in. Cannot save reminder.');
      }

      final reminder = ReminderModel(
        userId: userId,
        title: _titleController.text.trim(),
        locationName: _selectedLocation!.name,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        radius: _radius,
        createdAt: DateTime.now(),
      );

      final success = await appState.addReminder(reminder);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appState.errorMessage ?? 'Failed to save reminder'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save reminder: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No changes were needed in the build method.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              final isLoading = _isSaving || appState.isLoading;
              return TextButton(
                onPressed: isLoading ? null : _saveReminder,
                child: isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Saving...'),
                        ],
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) => Form(
          key: _formKey,
          child: Column(
            children: [
              if (appState.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        onPressed: appState.clearError,
                        icon: const Icon(Icons.close, size: 16),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Reminder Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit),
                          hintText: 'e.g., Pick up prescription',
                        ),
                        enabled: !_isSaving && !appState.isLoading,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a reminder title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Search for a location',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _selectedLocation != null
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : null,
                        ),
                        enabled: !_isSaving && !appState.isLoading,
                        onChanged: _onSearchChanged,
                        validator: (value) {
                          if (_selectedLocation == null) {
                            return 'Please select a location from the search results';
                          }
                          return null;
                        },
                      ),
                      if (_searchResults.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: _searchResults
                                .map(
                                  (result) => ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(result.name),
                                    subtitle: Text(result.address),
                                    onTap: () => _selectLocation(result),
                                    enabled:
                                        !_isSaving && !appState.isLoading,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      if (_selectedLocation != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Selected Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedLocation!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _selectedLocation!.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Trigger Radius',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Radius'),
                                    Text('${_radius.round()}m'),
                                  ],
                                ),
                                Slider(
                                  value: _radius,
                                  min: 50,
                                  max: 500,
                                  divisions: 9,
                                  onChanged:
                                      (_isSaving || appState.isLoading)
                                          ? null
                                          : (value) {
                                              setState(
                                                  () => _radius = value);
                                            },
                                ),
                                Text(
                                  'Reminder will trigger when you\'re within ${_radius.round()} meters',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}