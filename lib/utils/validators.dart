class Validators {
  /// Full name — required
  static String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    return null;
  }

  /// Email — required + format check
  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  /// Password — required + min length from constants
  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Confirm password — required + min length + must match
  static String? validateConfirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v.length < 8) {
      return 'Must be at least 8 characters';
    }
    if (v != password) return 'Passwords do not match';
    return null;
  }
}