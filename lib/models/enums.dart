// ── Meal Type ─────────────────────────────────────────────────────────────────

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExt on MealType {
  String get label => name[0].toUpperCase() + name.substring(1);

  String get emoji {
    switch (this) {
      case MealType.breakfast: return '🌅';
      case MealType.lunch:     return '☀️';
      case MealType.dinner:    return '🌙';
      case MealType.snack:     return '🍎';
    }
  }

  static MealType fromString(String s) =>
      MealType.values.firstWhere((e) => e.name == s, orElse: () => MealType.lunch);
}

// ── Fasting Protocol ──────────────────────────────────────────────────────────

enum FastingProtocol { h16_8, h18_6, h20_4, omad }

extension FastingProtocolExt on FastingProtocol {
  String get label {
    switch (this) {
      case FastingProtocol.h16_8: return '16:8';
      case FastingProtocol.h18_6: return '18:6';
      case FastingProtocol.h20_4: return '20:4';
      case FastingProtocol.omad:  return 'OMAD';
    }
  }

  int get targetHours {
    switch (this) {
      case FastingProtocol.h16_8: return 16;
      case FastingProtocol.h18_6: return 18;
      case FastingProtocol.h20_4: return 20;
      case FastingProtocol.omad:  return 23;
    }
  }

  String get description {
    switch (this) {
      case FastingProtocol.h16_8: return 'Fast 16h, eat 8h';
      case FastingProtocol.h18_6: return 'Fast 18h, eat 6h';
      case FastingProtocol.h20_4: return 'Fast 20h, eat 4h';
      case FastingProtocol.omad:  return 'One meal a day';
    }
  }

  static FastingProtocol fromHours(int h) {
    switch (h) {
      case 16: return FastingProtocol.h16_8;
      case 18: return FastingProtocol.h18_6;
      case 20: return FastingProtocol.h20_4;
      default: return FastingProtocol.omad;
    }
  }
}

// ── Shopping ──────────────────────────────────────────────────────────────────

const List<String> kShoppingCategories = [
  'Produce',
  'Protein',
  'Pantry',
  'Dairy',
  'Snacks',
  'Groceries',
  'Other',
];
