enum Gender {
  male,
  female,
  unspecified;
}

class UserProfile {
  static const int unknownBirthHour = 12;

  const UserProfile({
    required this.birthDate,
    this.birthHour = unknownBirthHour,
    this.gender = Gender.unspecified,
  });

  final DateTime birthDate;
  final int birthHour;
  final Gender gender;

  UserProfile copyWith({DateTime? birthDate, int? birthHour, Gender? gender}) {
    return UserProfile(
      birthDate: birthDate ?? this.birthDate,
      birthHour: birthHour ?? this.birthHour,
      gender: gender ?? this.gender,
    );
  }
}
