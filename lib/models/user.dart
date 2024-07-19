
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

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstname'] ?? '',
      pseudo: json['pseudo'] ?? '',
      password: json['password'] ?? '',
      description: json['description'] ?? "Salut ! J'utilise WhazApp.",
    );
  }

  @override
  List<Object?> get props => [id];
}