class Validators {
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

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (value.isNotEmpty &&
        value[0].toUpperCase() == value[0] &&
        value.contains(RegExp(r'\d'))) {
      return 'invalid password format';
    } else if (!RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$&*~]).{8,}$',
    ).hasMatch(value)) {
      return 'Must include uppercase, number, and special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (value.isNotEmpty &&
        value[0].toUpperCase() == value[0] &&
        value.contains(RegExp(r'\d'))) {
      return 'invalid password format';
    } else if (!RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$&*~]).{8,}$',
    ).hasMatch(value)) {
      return 'Must include uppercase, number, and special character';
    }
    return null;
  }
}
