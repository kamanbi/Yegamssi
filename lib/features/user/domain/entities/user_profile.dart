class UserProfile {
  static const int unknownBirthHour = 12;

  const UserProfile({
    required this.birthDate,
    this.birthHour = unknownBirthHour,
  });

  final DateTime birthDate;
  final int birthHour;

  UserProfile copyWith({DateTime? birthDate, int? birthHour}) {
    return UserProfile(
      birthDate: birthDate ?? this.birthDate,
      birthHour: birthHour ?? this.birthHour,
    );
  }
}
