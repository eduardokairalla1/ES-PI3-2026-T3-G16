/// --- UserProfile model ---

// --- CODE ---

/// I represent the authenticated user's profile data fetched from the backend.
class UserProfile {

  final String  uid;
  final String  email;
  final String  fullName;
  final String  cpf;
  final String  phone;
  final String  birthDate;
  final String? photoUrl;
  final bool    twoFaEnabled;


  const UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.cpf,
    required this.phone,
    required this.birthDate,
    this.photoUrl,
    this.twoFaEnabled = false,
  });


  /// I build a UserProfile from the map returned by the onGetProfile callable.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid:          map['uid']          as String,
      email:        map['email']        as String,
      fullName:     map['fullName']     as String,
      cpf:          map['cpf']          as String,
      phone:        map['phone']        as String,
      birthDate:    map['birthDate']    as String,
      photoUrl:     map['photoUrl']     as String?,
      twoFaEnabled: map['twoFaEnabled'] as bool? ?? false,
    );
  }


  /// I return a copy with updated fields.
  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? photoUrl,
    bool?   twoFaEnabled,
  }) {
    return UserProfile(
      uid:          uid,
      email:        email,
      fullName:     fullName     ?? this.fullName,
      cpf:          cpf,
      phone:        phone        ?? this.phone,
      birthDate:    birthDate,
      photoUrl:     photoUrl     ?? this.photoUrl,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
    );
  }
}
