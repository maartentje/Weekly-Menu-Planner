import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu.dart';
import '../models/app_state.dart';

class MenuCard extends StatefulWidget {
  final WeeklyMenu menu;
  final bool allowRegenerateDays;

  const MenuCard({
    super.key,
    required this.menu,
    this.allowRegenerateDays = false,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.menu.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Created on ${_formatDate(widget.menu.createdAt)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(),
          ...widget.menu.dailyMenus.map(
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
          if (widget.allowRegenerateDays)
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
    final appState = Provider.of<AppState>(context, listen: false);

    // Regenerate the specific day
    final updatedMenu = appState.regenerateDayInMenu(widget.menu, weekday);

    // Update the current menu if this is the current menu
    if (appState.currentMenu != null &&
        appState.currentMenu!.id == widget.menu.id) {
      appState.setCurrentMenu(updatedMenu);
    } else {
      // Update the menu in the list
      appState.updateMenuInList(widget.menu.id, updatedMenu);
    }

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
