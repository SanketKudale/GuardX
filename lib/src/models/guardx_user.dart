class GuardXUser {
  const GuardXUser({
    this.id,
    this.email,
    this.name,
  });

  final String? id;
  final String? email;
  final String? name;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
    };
  }

  factory GuardXUser.fromJson(Map<String, dynamic> json) {
    return GuardXUser(
      id: json['id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
    );
  }
}
