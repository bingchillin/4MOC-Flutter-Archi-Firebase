
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
    this.description = "Salut ! J'utilise WhazApp.",
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      pseudo: json['pseudo'],
      password: json['password'],
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id];
}