
class UserSession {
  static final UserSession instance = UserSession._internal();

  String? userId;
  String? userName;

  UserSession._internal();

  void initialize(String id,String name) {
    userId = id;
    userName = name;
  }

  void clear() {
    userId = null;
    userName = null;
  }
}
