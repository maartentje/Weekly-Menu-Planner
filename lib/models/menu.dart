import 'recipe.dart';

class DailyMenu {
  final String weekday;
  final Recipe? recipe;

  DailyMenu({
    required this.weekday,
    this.recipe,
  });

  DailyMenu copyWith({
    String? weekday,
    Recipe? recipe,
  }) {
    return DailyMenu(
      weekday: weekday ?? this.weekday,
      recipe: recipe ?? this.recipe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'recipe': recipe?.toJson(),
    };
  }

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    return DailyMenu(
      weekday: json['weekday'],
      recipe: json['recipe'] != null ? Recipe.fromJson(json['recipe']) : null,
    );
  }
}

class WeeklyMenu {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<DailyMenu> dailyMenus;
  final bool isFavorite;

  WeeklyMenu({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.dailyMenus,
    this.isFavorite = false,
  });

  WeeklyMenu copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<DailyMenu>? dailyMenus,
    bool? isFavorite,
  }) {
    return WeeklyMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      dailyMenus: dailyMenus ?? this.dailyMenus,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'dailyMenus': dailyMenus.map((dm) => dm.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  factory WeeklyMenu.fromJson(Map<String, dynamic> json) {
    return WeeklyMenu(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      dailyMenus: (json['dailyMenus'] as List)
          .map((dm) => DailyMenu.fromJson(dm))
          .toList(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
