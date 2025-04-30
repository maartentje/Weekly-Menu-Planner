import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe.dart';
import 'menu.dart';
import 'day_preference.dart';

class AppState with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<WeeklyMenu> _menus = [];
  WeeklyMenu? _currentMenu;
  List<DayPreference> _dayPreferences = [];
  List<String> _availableTags = [];

  // Getters
  List<Recipe> get recipes => _recipes;
  List<WeeklyMenu> get menus => _menus;
  WeeklyMenu? get currentMenu => _currentMenu;
  List<DayPreference> get dayPreferences => _dayPreferences;
  List<String> get availableTags => _availableTags;

  AppState() {
    _loadData();
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load recipes
    final recipesJson = prefs.getStringList('recipes') ?? [];
    _recipes =
        recipesJson.map((json) => Recipe.fromJson(jsonDecode(json))).toList();

    // Load menus
    final menusJson = prefs.getStringList('menus') ?? [];
    _menus =
        menusJson.map((json) => WeeklyMenu.fromJson(jsonDecode(json))).toList();

    // Load current menu
    final currentMenuJson = prefs.getString('currentMenu');
    if (currentMenuJson != null) {
      _currentMenu = WeeklyMenu.fromJson(jsonDecode(currentMenuJson));
    }

    // Load day preferences
    final dayPreferencesJson = prefs.getStringList('dayPreferences') ?? [];
    _dayPreferences =
        dayPreferencesJson
            .map((json) => DayPreference.fromJson(jsonDecode(json)))
            .toList();

    // Initialize day preferences if empty
    if (_dayPreferences.isEmpty) {
      _initializeDayPreferences();
    }

    // Extract all available tags from recipes
    _updateAvailableTags();

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save recipes
    final recipesJson =
        _recipes.map((recipe) => jsonEncode(recipe.toJson())).toList();
    await prefs.setStringList('recipes', recipesJson);

    // Save menus
    final menusJson = _menus.map((menu) => jsonEncode(menu.toJson())).toList();
    await prefs.setStringList('menus', menusJson);

    // Save current menu
    if (_currentMenu != null) {
      await prefs.setString('currentMenu', jsonEncode(_currentMenu!.toJson()));
    } else {
      await prefs.remove('currentMenu');
    }

    // Save day preferences
    final dayPreferencesJson =
        _dayPreferences.map((pref) => jsonEncode(pref.toJson())).toList();
    await prefs.setStringList('dayPreferences', dayPreferencesJson);
  }

  void _initializeDayPreferences() {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    _dayPreferences =
        weekdays
            .map(
              (day) => DayPreference(
                weekday: day,
                preferredTags: [],
                excludedTags: [],
              ),
            )
            .toList();
  }

  void _updateAvailableTags() {
    final Set<String> tags = {};
    for (final recipe in _recipes) {
      tags.addAll(recipe.tags);
    }
    _availableTags = tags.toList()..sort();
  }

  // Recipe methods
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    _updateAvailableTags();
    _saveData();
    notifyListeners();
  }

  void updateRecipe(Recipe updatedRecipe) {
    final index = _recipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      _updateAvailableTags();
      _saveData();
      notifyListeners();
    }
  }

  void deleteRecipe(String recipeId) {
    _recipes.removeWhere((r) => r.id == recipeId);
    _updateAvailableTags();
    _saveData();
    notifyListeners();
  }

  void toggleRecipeFavorite(String recipeId) {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      final recipe = _recipes[index];
      _recipes[index] = recipe.copyWith(isFavorite: !recipe.isFavorite);
      _saveData();
      notifyListeners();
    }
  }

  // Menu methods
  void setCurrentMenu(WeeklyMenu menu) {
    _currentMenu = menu;
    _saveData();
    notifyListeners();
  }

  void addMenu(WeeklyMenu menu) {
    _menus.add(menu);
    _currentMenu = menu;
    _saveData();
    notifyListeners();
  }

  void updateMenuInList(String menuId, WeeklyMenu updatedMenu) {
    final index = menus.indexWhere((m) => m.id == menuId);
    if (index != -1) {
      menus[index] = updatedMenu;
      notifyListeners();
    }
  }

  void deleteMenu(String menuId) {
    _menus.removeWhere((m) => m.id == menuId);
    if (_currentMenu != null && _currentMenu!.id == menuId) {
      _currentMenu = _menus.isNotEmpty ? _menus.first : null;
    }
    _saveData();
    notifyListeners();
  }

  void toggleMenuFavorite(String menuId) {
    final index = _menus.indexWhere((m) => m.id == menuId);
    if (index != -1) {
      final menu = _menus[index];
      _menus[index] = menu.copyWith(isFavorite: !menu.isFavorite);
      if (_currentMenu != null && _currentMenu!.id == menuId) {
        _currentMenu = _menus[index];
      }
      _saveData();
      notifyListeners();
    }
  }

  // Day preference methods
  void updateDayPreference(DayPreference updatedPreference) {
    final index = _dayPreferences.indexWhere(
      (p) => p.weekday == updatedPreference.weekday,
    );
    if (index != -1) {
      _dayPreferences[index] = updatedPreference;
      _saveData();
      notifyListeners();
    }
  }

  // Generate a weekly menu based on preferences
  WeeklyMenu generateWeeklyMenu() {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final List<DailyMenu> dailyMenus = [];
    final List<String> usedRecipeIds = [];

    for (final weekday in weekdays) {
      final preference = _dayPreferences.firstWhere(
        (p) => p.weekday == weekday,
        orElse:
            () => DayPreference(
              weekday: weekday,
              preferredTags: [],
              excludedTags: [],
            ),
      );

      // Filter recipes based on day preferences
      final availableRecipes =
          _recipes.where((recipe) {
            // Skip already used recipes
            if (usedRecipeIds.contains(recipe.id)) return false;

            // Check if recipe has any excluded tags
            for (final tag in preference.excludedTags) {
              if (recipe.tags.contains(tag)) return false;
            }

            // Check if recipe has all preferred tags
            if (preference.preferredTags.isNotEmpty) {
              for (final tag in preference.preferredTags) {
                if (!recipe.tags.contains(tag)) return false;
              }
            }

            return true;
          }).toList();

      // If no recipes match the criteria, try with just excluding the excluded tags
      if (availableRecipes.isEmpty) {
        final fallbackRecipes =
            _recipes.where((recipe) {
              if (usedRecipeIds.contains(recipe.id)) return false;

              for (final tag in preference.excludedTags) {
                if (recipe.tags.contains(tag)) return false;
              }

              return true;
            }).toList();

        if (fallbackRecipes.isNotEmpty) {
          fallbackRecipes.shuffle();
          final selectedRecipe = fallbackRecipes.first;
          usedRecipeIds.add(selectedRecipe.id);
          dailyMenus.add(DailyMenu(weekday: weekday, recipe: selectedRecipe));
        } else {
          dailyMenus.add(DailyMenu(weekday: weekday));
        }
      } else {
        availableRecipes.shuffle();
        final selectedRecipe = availableRecipes.first;
        usedRecipeIds.add(selectedRecipe.id);
        dailyMenus.add(DailyMenu(weekday: weekday, recipe: selectedRecipe));
      }
    }

    final newMenu = WeeklyMenu(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Menu ${_menus.length + 1}',
      createdAt: DateTime.now(),
      dailyMenus: dailyMenus,
    );

    return newMenu;
  }

  // NEW METHOD: Regenerate a specific day in a menu
  WeeklyMenu regenerateDayInMenu(WeeklyMenu menu, String weekday) {
    // Get all recipe IDs currently used in the menu (except the one we're replacing)
    final List<String> usedRecipeIds =
        menu.dailyMenus
            .where((dm) => dm.weekday != weekday && dm.recipe != null)
            .map((dm) => dm.recipe!.id)
            .toList();

    // Get the day preference for the specified weekday
    final preference = _dayPreferences.firstWhere(
      (p) => p.weekday == weekday,
      orElse:
          () => DayPreference(
            weekday: weekday,
            preferredTags: [],
            excludedTags: [],
          ),
    );

    // Filter recipes based on day preferences
    final availableRecipes =
        _recipes.where((recipe) {
          // Skip already used recipes
          if (usedRecipeIds.contains(recipe.id)) return false;

          // Check if recipe has any excluded tags
          for (final tag in preference.excludedTags) {
            if (recipe.tags.contains(tag)) return false;
          }

          // Check if recipe has all preferred tags
          if (preference.preferredTags.isNotEmpty) {
            for (final tag in preference.preferredTags) {
              if (!recipe.tags.contains(tag)) return false;
            }
          }

          return true;
        }).toList();

    // If no recipes match the criteria, try with just excluding the excluded tags
    Recipe? selectedRecipe;
    if (availableRecipes.isEmpty) {
      final fallbackRecipes =
          _recipes.where((recipe) {
            if (usedRecipeIds.contains(recipe.id)) return false;

            for (final tag in preference.excludedTags) {
              if (recipe.tags.contains(tag)) return false;
            }

            return true;
          }).toList();

      if (fallbackRecipes.isNotEmpty) {
        fallbackRecipes.shuffle();
        selectedRecipe = fallbackRecipes.first;
      }
    } else {
      availableRecipes.shuffle();
      selectedRecipe = availableRecipes.first;
    }

    // Create a new list of daily menus with the updated day
    final List<DailyMenu> updatedDailyMenus =
        menu.dailyMenus.map((dailyMenu) {
          if (dailyMenu.weekday == weekday) {
            return DailyMenu(weekday: weekday, recipe: selectedRecipe);
          }
          return dailyMenu;
        }).toList();

    // Return a new menu with the updated daily menus
    return menu.copyWith(dailyMenus: updatedDailyMenus);
  }
}
