class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final int preparationTime; // in minutes
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.preparationTime,
    this.isFavorite = false,
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    int? preparationTime,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      preparationTime: preparationTime ?? this.preparationTime,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'preparationTime': preparationTime,
      'isFavorite': isFavorite,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      preparationTime: json['preparationTime'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
