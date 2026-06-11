class Validators {
  static String? validateRequiredField(
    String? value, {
    required String fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  static String? validateLastNAme(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Address is required';
    } else if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'Invalid phone number';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$&*~]).{8,}$',
    ).hasMatch(value)) {
      return 'Must include uppercase, number, and special character';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value, {
    required String password,
  }) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$&*~]).{8,}$',
    ).hasMatch(value)) {
      return 'Must include uppercase, number, and special character';
    } else if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateBirthday(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Birthday is required';
    }
    return null;
  }
}
