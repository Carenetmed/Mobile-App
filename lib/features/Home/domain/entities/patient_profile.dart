class PatientProfile {
  const PatientProfile({
    this.id,
    required this.name,
    this.age,
    this.location,
    this.dateOfBirth,
    this.city,
    this.state,
    this.country,
    this.healthInterests,
  });

  final String? id;
  final String name;
  final int? age;
  final String? location;
  final DateTime? dateOfBirth;
  final String? city;
  final String? state;
  final String? country;
  final String? healthInterests;
}
