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
    if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value.trim())) {
      return 'Unesite ispravan e-mail.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon je obavezan.';
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
      return 'Dozvoljena su slova, brojevi, tačka i donja crta';
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
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])',
    ).hasMatch(value)) {
      return 'Lozinka mora sadržavati velika i mala slova, broj i spec. znak.';
    }
    return null;
  }

  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezan.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-zčćžšđČĆŽŠĐ\s-']+$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName smije sadržavati samo slova, razmake, crtice i apostrofe.';
    }
    return null;
  }

  static String? validateSimpleName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezno.';
    }
    if (value.length > 100) {
      return '$fieldName ne smije imati više od 100 znakova.';
    }
    final regex = RegExp(r"^[A-Za-zčćžšđČĆŽŠĐ\s-]+$");
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
