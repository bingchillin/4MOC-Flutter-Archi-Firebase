
class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String pseudo;
  final String password;
  final String description;

  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.pseudo,
    required this.password,
    required this.description,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, String id) {
    return AppUser(
      id: id,
      email: json['email'] ?? '',
      firstName: json['prenom'] ?? '',
      pseudo: json['pseudo'] ?? '',
      password: json['password'] ?? '',
      description: json['description'] ?? "Salut ! J'utilise WhazApp.",
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? pseudo,
    String? password,
    String? description,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      pseudo: pseudo ?? this.pseudo,
      password: password ?? this.password,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id];
}