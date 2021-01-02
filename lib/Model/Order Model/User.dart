class User {
  String uid;
  String fullName;
  String phoneNr;
  String email;

  User({this.uid, this.fullName, this.phoneNr, this.email});

  User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        fullName = json['fullName'],
        phoneNr = json['phoneNr'],
        email = json['email'];

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'phoneNr': phoneNr,
        'email': email,
      };

      @override
  String toString() {
    return '$fullName, $phoneNr, $email';
  }
}
