class User {
  String userId;
  String? username;
  String email;

  User({required this.userId, this.username, required this.email});

//   User? getInstance(String inputId, String inputName, String inputEmail) {
//     if (_instance == null) {
//       User(id: inputId, name: inputName, email: inputEmail);
//     }

//     return _instance;
//   }

//   void clearInstance() {
//     _instance = null;
//   }

  String get getUserId => userId;
  String get getUsername => username ?? "";
  String get getEmail => email;

  set setUserId(String userId) {
    this.userId = userId;
  }

  set setUsername(String username) {
    this.username = username;
  }

  set setEmail(String email) {
    this.email = email;
  }
}