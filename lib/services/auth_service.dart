class AuthService {
  // ============================================================
  // STATUS LOGIN USER
  // ============================================================
  //
  // SEMENTARA:
  // false = belum login
  // true  = sudah login
  //
  // Nanti bagian ini bisa diganti dengan sistem login
  // asli dari API / PHP / MySQL / Firebase.
  // ============================================================

  static bool isLoggedIn = false;

  // ============================================================
  // CEK STATUS LOGIN
  // ============================================================

  static bool checkLogin() {
    return isLoggedIn;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static void login() {
    isLoggedIn = true;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static void logout() {
    isLoggedIn = false;
  }
}