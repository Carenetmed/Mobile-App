class PublicProfessional {
  const PublicProfessional({
    required this.id,
    required this.displayName,
    required this.category,
    this.specialty,
    this.bio,
    required this.verified,
  });

  final String id;
  final String displayName;
  final String category;
  final String? specialty;
  final String? bio;
  final bool verified;
}
