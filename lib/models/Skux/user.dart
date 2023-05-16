class SkuxUser {
  String id;
  String email;
  String displayName;
  String firstName;
  String lastName;
  String mobile;
  bool hasIdentityProvider;

  SkuxUser({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.mobile,
    this.hasIdentityProvider,
  });

  SkuxUser.fromJson(Map<String, dynamic> json) {
    id = json['uuid'];
    email = json['profile']['emailAddress'];
    displayName = json['profile']['displayName'];
    mobile = json['phoneNumber'];
    hasIdentityProvider = json['profile']['hasIdentityProvider'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = id;
    data['profile'] = {};
    data['profile']['emailAddress'] = email;
    data['profile']['firstName'] = firstName;
    data['profile']['lastName'] = lastName;
    data['profile']['displayName'] = displayName;
    data['phoneNumber'] = mobile;
    data['profile']['hasIdentityProvider'] = hasIdentityProvider;
    return data;
  }
}
