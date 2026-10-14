import 'package:intl/intl.dart';
import 'package:app_t/core/presentation/carenet_presentation.dart';

String formatNgnMinor(int amountMinor) {
  final negative = amountMinor < 0;
  final absolute = amountMinor.abs();
  final major = absolute ~/ 100;
  final minor = (absolute % 100).toString().padLeft(2, '0');
  final formattedMajor = NumberFormat.decimalPattern(
    CareNetPresentation.numberLocale,
  ).format(major);
  return '${negative ? '-' : ''}NGN $formattedMajor.$minor';
}

int? parseNgnMajorToMinor(String value) {
  final normalized = value.trim();
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) {
    return null;
  }
  final parts = normalized.split('.');
  final major = int.tryParse(parts[0]);
  if (major == null) {
    return null;
  }
  final minorText = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
  final minor = int.tryParse(minorText);
  if (minor == null) {
    return null;
  }
  return major * 100 + minor;
}

int calculatePlatformFeeMinor(int grossAmountMinor, {int basisPoints = 1500}) {
  if (grossAmountMinor < 0 || basisPoints < 0 || basisPoints > 10000) {
    throw ArgumentError('Money and basis points must be within range.');
  }
  return (grossAmountMinor * basisPoints + 5000) ~/ 10000;
}
