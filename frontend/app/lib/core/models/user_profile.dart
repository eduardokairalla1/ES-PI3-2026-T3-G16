/// --- UserProfile model ---

// --- CODE ---

/// I represent the authenticated user's profile data fetched from the backend.
class UserProfile {

  // attributes
  final String  uid;
  final String  email;
  final String  fullName;
  final String  cpf;
  final String  phone;
  final String  birthDate;
  final String  status;


  // constructor
  const UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.cpf,
    required this.phone,
    required this.birthDate,
    required this.status,
  });


  /// I build a UserProfile from the map returned by the onGetProfile callable.
  ///
  /// :param map: the raw data map from the Cloud Function response
  ///
  /// :returns: a UserProfile instance
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid:       map['uid']       as String,
      email:     map['email']     as String,
      fullName:  map['fullName']  as String,
      cpf:       map['cpf']       as String,
      phone:     map['phone']     as String,
      birthDate: map['birthDate'] as String,
      status:    map['status']    as String,
    );
  }
}
