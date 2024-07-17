
class User {
  final String id;
  final String email;
  final String firstName;
  final String pseudo;
  final String password;
  final String description;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.pseudo,
    required this.password,
    this.description = "Salut ! J'utilise WhazApp.",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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