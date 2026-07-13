class ProfessionalProfile {
  const ProfessionalProfile({
    this.id,
    required this.displayName,
    required this.category,
    this.specialty,
    this.bio,
    this.verificationStatus,
  });

  final String? id;
  final String displayName;
  final String category;
  final String? specialty;
  final String? bio;
  final String? verificationStatus;
}
