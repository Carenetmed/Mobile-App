class MessagingRealtimeIdentity {
  const MessagingRealtimeIdentity({
    required this.userId,
    required this.generation,
    required this.role,
  });

  final String userId;
  final String generation;
  final String role;

  bool get isSupported =>
      userId.trim().isNotEmpty &&
      generation.trim().isNotEmpty &&
      const <String>{'PATIENT', 'PROFESSIONAL'}.contains(role);

  bool matches(MessagingRealtimeIdentity other) =>
      userId == other.userId &&
      generation == other.generation &&
      role == other.role;
}

class MessagingRealtimeCredentials {
  const MessagingRealtimeCredentials({
    required this.identity,
    required this.accessToken,
  });

  final MessagingRealtimeIdentity identity;
  final String accessToken;

  bool get isUsable =>
      identity.isSupported &&
      accessToken.trim().isNotEmpty &&
      accessToken.trim() == accessToken;
}
