class Teacher {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String dni;
  final String address;
  final String phone;
  final int administratorId;
  final String username;
  final String password;

  Teacher({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dni,
    required this.address,
    required this.phone,
    required this.administratorId,
    required this.username,
    required this.password,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      dni: json['dni'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      administratorId: json['administratorId'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dni': dni,
      'address': address,
      'phone': phone,
      'administratorId': administratorId,
      'username': username,
      'password': password,
    };
  }
}
