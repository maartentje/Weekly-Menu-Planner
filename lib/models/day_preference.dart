class DayPreference {
  final String weekday;
  final List<String> preferredTags;
  final List<String> excludedTags;

  DayPreference({
    required this.weekday,
    required this.preferredTags,
    required this.excludedTags,
  });

  DayPreference copyWith({
    String? weekday,
    List<String>? preferredTags,
    List<String>? excludedTags,
  }) {
    return DayPreference(
      weekday: weekday ?? this.weekday,
      preferredTags: preferredTags ?? this.preferredTags,
      excludedTags: excludedTags ?? this.excludedTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'preferredTags': preferredTags,
      'excludedTags': excludedTags,
    };
  }

  factory DayPreference.fromJson(Map<String, dynamic> json) {
    return DayPreference(
      weekday: json['weekday'],
      preferredTags: List<String>.from(json['preferredTags']),
      excludedTags: List<String>.from(json['excludedTags']),
    );
  }
}
