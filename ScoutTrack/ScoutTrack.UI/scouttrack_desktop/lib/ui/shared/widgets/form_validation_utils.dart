class FormValidationUtils {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    return null;
  }

  static String? validateLength(
    String? value,
    String fieldName,
    int maxLength,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName ne smije imati više od $maxLength znakova.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail je obavezan.';
    }
    if (value.length > 100) {
      return 'E-mail ne smije imati više od 100 znakova.';
    }
    if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value.trim())) {
      return 'Unesite ispravan e-mail.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon je obavezan.';
    }
    if (value.length > 20) {
      return 'Telefon ne smije imati više od 20 znakova.';
    }
    if (!RegExp(
      r'^(\+387|0)[6][0-7][0-9][0-9][0-9][0-9][0-9][0-9]$',
    ).hasMatch(value)) {
      return 'Broj telefona mora biti validan za Bosnu i Hercegovinu.';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Korisničko ime je obavezno.';
    }
    if (value.length > 50) {
      return 'Korisničko ime ne smije imati više od 50 znakova.';
    }
    if (!RegExp(r"^[A-Za-z0-9_.]+$").hasMatch(value.trim())) {
      return 'Korisničko ime može sadržavati samo slova, brojeve, tačke, donje crte ili crtice.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lozinka je obavezna.';
    }
    if (value.length < 8) {
      return 'Lozinka mora imati najmanje 8 znakova.';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$',
    ).hasMatch(value)) {
      return 'Lozinka mora sadržavati velika i mala slova, broj i spec. znak.';
    }
    return null;
  }

  // For Activity and Equipment names - allows letters, numbers, special chars, spaces, hyphens, apostrophes
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
    }
    return null;
  }

  // For Troop names - allows letters, numbers, special chars, spaces, hyphens, apostrophes
  static String? validateTroopName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
    }
    return null;
  }

  // For City names - allows only letters, spaces, and hyphens
  static String? validateCityName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$");
    if (!regex.hasMatch(value.trim())) {
      return 'Naziv grada može sadržavati samo slova (A-Ž, a-ž), razmake i crtice (-).';
    }
    return null;
  }

  // For Activity Type names - allows letters, numbers, special chars, spaces, hyphens, apostrophes
  static String? validateActivityTypeName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
    }
    return null;
  }

  // For Activity Title and Location Name - allows letters, numbers, special chars, spaces, hyphens, apostrophes
  static String? validateActivityTitle(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
    }
    return null;
  }

  static String? validateActivityLocationName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 200) {
      return '$fieldName ne smije imati više od 200 znakova.';
    }
    final regex = RegExp(r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
    }
    return null;
  }

  static String? validateActivityDescription(String? value, String fieldName) {
    if (value != null && value.length > 500) {
      return '$fieldName ne smije imati više od 500 znakova.';
    }
    return null;
  }

  static String? validateActivitySummary(String? value, String fieldName) {
    if (value != null && value.length > 2000) {
      return '$fieldName ne smije imati više od 2000 znakova.';
    }
    return null;
  }

  static String? validateEquipmentDescription(String? value, String fieldName) {
    if (value != null && value.length > 500) {
      return '$fieldName ne smije imati više od 500 znakova.';
    }
    return null;
  }

  static String? validateActivityTypeDescription(
    String? value,
    String fieldName,
  ) {
    if (value != null && value.length > 500) {
      return '$fieldName ne smije imati više od 500 znakova.';
    }
    return null;
  }

  // For Member names - allows letters, numbers, spaces, hyphens, apostrophes
  static String? validateMemberName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 50) {
      return '$fieldName ne smije imati više od 50 znakova.';
    }
    final regex = RegExp(r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
    }
    return null;
  }

  // For Troop ScoutMaster and TroopLeader - allows letters, numbers, spaces, hyphens, apostrophes
  static String? validateTroopPersonName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-z0-9ČčĆćŽžĐđŠš\s\-\']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName može sadržavati samo slova (A-Ž, a-ž), brojeve (0-9), razmake, crtice (-) i apostrofe (\').';
    }
    return null;
  }

  // Legacy method for backward compatibility
  static String? validateSimpleName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezno.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName smije sadržavati samo slova, razmake i crtice.';
    }
    return null;
  }

  static String? validateDropdown(dynamic value, String fieldName) {
    if (value == null) {
      return '$fieldName je obavezan.';
    }
    return null;
  }

  static String? validateMatch(
    String? value,
    String? matchValue,
    String fieldName,
  ) {
    if (value != matchValue) {
      return '$fieldName se ne poklapaju.';
    }
    return null;
  }

  static String? validateNumericRange(
    int? value,
    String fieldName,
    int min,
    int max,
  ) {
    if (value == null) {
      return '$fieldName je obavezan.';
    }
    if (value < min || value > max) {
      return '$fieldName mora biti između $min i $max.';
    }
    return null;
  }

  static String? validateLatitude(double? value) {
    if (value == null) {
      return 'Geografska širina je obavezna.';
    }
    if (value < -90 || value > 90) {
      return 'Geografska širina mora biti između -90 i 90.';
    }
    return null;
  }

  static String? validateLongitude(double? value) {
    if (value == null) {
      return 'Geografska dužina je obavezna.';
    }
    if (value < -180 || value > 180) {
      return 'Geografska dužina mora biti između -180 i 180.';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL je obavezan.';
    }
    if (!RegExp(r'^https?://.+').hasMatch(value.trim())) {
      return 'Unesite ispravan URL (počinje sa http:// ili https://).';
    }
    return null;
  }
}
