enum PasswordCategory {
  social,
  entertainment,
  banking,
  work,
  ecommerce,
  utilities,
  travel,
  education,
  health,
  government,
  others,
}

extension PasswordCategoryExtension on PasswordCategory {
  String get name {
    switch (this) {
      case PasswordCategory.social:
        return "Social";
      case PasswordCategory.entertainment:
        return "Entertainment";
      case PasswordCategory.banking:
        return "Banking";
      case PasswordCategory.work:
        return "Work";
      case PasswordCategory.ecommerce:
        return "E-commerce";
      case PasswordCategory.utilities:
        return "Utilities";
      case PasswordCategory.travel:
        return "Travel";
      case PasswordCategory.education:
        return "Education";
      case PasswordCategory.health:
        return "Health";
      case PasswordCategory.government:
        return "Government";
      case PasswordCategory.others:
        return "Others";
    }
  }
}
