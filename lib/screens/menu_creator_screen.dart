import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/menu.dart';

class MenuCreatorScreen extends StatefulWidget {
  const MenuCreatorScreen({super.key});

  @override
  State<MenuCreatorScreen> createState() => _MenuCreatorScreenState();
}

class _MenuCreatorScreenState extends State<MenuCreatorScreen> {
  WeeklyMenu? _generatedMenu;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Menu ${DateTime.now().day}/${DateTime.now().month}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Menu')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Menu Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final appState = Provider.of<AppState>(
                              context,
                              listen: false,
                            );

                            if (appState.recipes.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You need to add recipes before creating a menu',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _generatedMenu = appState.generateWeeklyMenu();
                              if (_nameController.text.isNotEmpty) {
                                _generatedMenu = _generatedMenu!.copyWith(
                                  name: _nameController.text,
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Generate Menu'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_generatedMenu != null) ...[
                          const Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMenuPreview(),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      final appState = Provider.of<AppState>(
                                        context,
                                        listen: false,
                                      );
                                      _generatedMenu =
                                          appState.generateWeeklyMenu();
                                      if (_nameController.text.isNotEmpty) {
                                        _generatedMenu = _generatedMenu!
                                            .copyWith(
                                              name: _nameController.text,
                                            );
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Regenerate All'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final appState = Provider.of<AppState>(
                                      context,
                                      listen: false,
                                    );
                                    appState.addMenu(_generatedMenu!);
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save Menu'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuPreview() {
    if (_generatedMenu == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _generatedMenu!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Created on ${_formatDate(_generatedMenu!.createdAt)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(),
          ..._generatedMenu!.dailyMenus.map(
            (dailyMenu) => _buildDailyMenuItem(dailyMenu),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMenuItem(DailyMenu dailyMenu) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              dailyMenu.weekday,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child:
                dailyMenu.recipe != null
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dailyMenu.recipe!.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dailyMenu.recipe!.tags.join(', '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                    : const Text(
                      'No recipe assigned',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
          ),
          if (dailyMenu.recipe != null)
            Text(
              '${dailyMenu.recipe!.preparationTime} min',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Regenerate this day',
            onPressed: () => _regenerateDay(dailyMenu.weekday),
          ),
        ],
      ),
    );
  }

  Future<void> _regenerateDay(String weekday) async {
    if (_generatedMenu == null) return;

    final appState = Provider.of<AppState>(context, listen: false);

    // Regenerate the specific day
    setState(() {
      _generatedMenu = appState.regenerateDayInMenu(_generatedMenu!, weekday);
    });

    // Show a confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Regenerated dish for $weekday'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
