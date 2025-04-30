import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/menu.dart';
import '../widgets/menu_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Menu Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final currentMenu = appState.currentMenu;

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (currentMenu != null) ...[
                            const Text(
                              'Current Menu',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            MenuCard(
                              menu: currentMenu,
                              allowRegenerateDays: true,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Previous Menus',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ] else ...[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No menu created yet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Create a new menu to get started',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ]),
                      ),
                    ),

                    // Previous menus list (only if there's a current menu)
                    if (currentMenu != null)
                      appState.menus.isEmpty
                          ? SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'No previous menus',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                          : SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final menu = appState.menus[index];
                                return ListTile(
                                  title: Text(menu.name),
                                  subtitle: Text(
                                    'Created on ${_formatDate(menu.createdAt)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          menu.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              menu.isFavorite
                                                  ? Colors.red
                                                  : null,
                                        ),
                                        onPressed: () {
                                          Provider.of<AppState>(
                                            context,
                                            listen: false,
                                          ).toggleMenuFavorite(menu.id);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          _confirmDeleteMenu(context, menu);
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Provider.of<AppState>(
                                      context,
                                      listen: false,
                                    ).setCurrentMenu(menu);
                                  },
                                );
                              }, childCount: appState.menus.length),
                            ),
                          ),

                    // Add extra padding at the bottom to ensure the last item is visible above the FAB
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 80,
                      ), // Height to accommodate the FAB
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/menu_creator');
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Menu'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/recipes');
          } else if (index == 2) {
            // Show favorites
            _showFavorites(context);
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDeleteMenu(BuildContext context, WeeklyMenu menu) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Menu'),
            content: Text('Are you sure you want to delete "${menu.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).deleteMenu(menu.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showFavorites(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final favoriteMenus = appState.menus.where((m) => m.isFavorite).toList();
    final favoriteRecipes =
        appState.recipes.where((r) => r.isFavorite).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Favorites'),
                    bottom: const TabBar(
                      tabs: [Tab(text: 'Menus'), Tab(text: 'Recipes')],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      // Favorite Menus
                      favoriteMenus.isEmpty
                          ? const Center(child: Text('No favorite menus'))
                          : ListView.builder(
                            controller: scrollController,
                            itemCount: favoriteMenus.length,
                            itemBuilder: (context, index) {
                              final menu = favoriteMenus[index];
                              return ListTile(
                                title: Text(menu.name),
                                subtitle: Text(
                                  'Created on ${_formatDate(menu.createdAt)}',
                                ),
                                onTap: () {
                                  appState.setCurrentMenu(menu);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),

                      // Favorite Recipes
                      favoriteRecipes.isEmpty
                          ? const Center(child: Text('No favorite recipes'))
                          : ListView.builder(
                            controller: scrollController,
                            itemCount: favoriteRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = favoriteRecipes[index];
                              return ListTile(
                                title: Text(recipe.name),
                                subtitle: Text(recipe.tags.join(', ')),
                                trailing: Text('${recipe.preparationTime} min'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/recipes');
                                },
                              );
                            },
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
