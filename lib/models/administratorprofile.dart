class AdministratorProfile {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String dni;
  final String address;
  final String phone;
  final String? username;
  final String? password;

  AdministratorProfile({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dni,
    required this.address,
    required this.phone,
    this.username,
    this.password,
  });

  factory AdministratorProfile.fromJson(Map<String, dynamic> json) {
    return AdministratorProfile(
      id: json['id'] as int?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dni': dni,
      'address': address,
      'phone': phone,
    };
    if (id != null) data['id'] = id;
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    return data;
  }
}
