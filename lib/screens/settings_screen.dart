import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/day_preference.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              // Main content
              Expanded(
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Day Preferences',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Set your preferences for each day of the week. The menu generator will try to match recipes with your preferences.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...appState.dayPreferences.map(
                      (preference) => _buildDayPreferenceCard(
                        context,
                        preference,
                        appState.availableTags,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayPreferenceCard(
    BuildContext context,
    DayPreference preference,
    List<String> availableTags,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        title: Text(preference.weekday),
        subtitle: Text(
          preference.preferredTags.isEmpty
              ? 'No preferences set'
              : 'Preferred: ${preference.preferredTags.join(', ')}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferred Tags',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ...preference.preferredTags.map(
                      (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          final updatedPreference = preference.copyWith(
                            preferredTags: List.from(preference.preferredTags)
                              ..remove(tag),
                          );
                          Provider.of<AppState>(
                            context,
                            listen: false,
                          ).updateDayPreference(updatedPreference);
                        },
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: () {
                        _showTagSelectionDialog(
                          context,
                          preference,
                          availableTags,
                          true,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Excluded Tags',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ...preference.excludedTags.map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.red.shade100,
                        onDeleted: () {
                          final updatedPreference = preference.copyWith(
                            excludedTags: List.from(preference.excludedTags)
                              ..remove(tag),
                          );
                          Provider.of<AppState>(
                            context,
                            listen: false,
                          ).updateDayPreference(updatedPreference);
                        },
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: () {
                        _showTagSelectionDialog(
                          context,
                          preference,
                          availableTags,
                          false,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTagSelectionDialog(
    BuildContext context,
    DayPreference preference,
    List<String> availableTags,
    bool isPreferred,
  ) {
    final List<String> currentTags =
        isPreferred ? preference.preferredTags : preference.excludedTags;
    final List<String> otherTags =
        isPreferred ? preference.excludedTags : preference.preferredTags;

    // Filter out tags that are already selected in either list
    final List<String> availableToSelect =
        availableTags
            .where(
              (tag) => !currentTags.contains(tag) && !otherTags.contains(tag),
            )
            .toList();

    if (availableToSelect.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No more tags available. Add more recipes with different tags.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Select ${isPreferred ? 'Preferred' : 'Excluded'} Tags',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    availableToSelect
                        .map(
                          (tag) => ListTile(
                            title: Text(tag),
                            onTap: () {
                              List<String> updatedTags = List.from(currentTags)
                                ..add(tag);
                              final updatedPreference =
                                  isPreferred
                                      ? preference.copyWith(
                                        preferredTags: updatedTags,
                                      )
                                      : preference.copyWith(
                                        excludedTags: updatedTags,
                                      );

                              Provider.of<AppState>(
                                context,
                                listen: false,
                              ).updateDayPreference(updatedPreference);
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }
}
