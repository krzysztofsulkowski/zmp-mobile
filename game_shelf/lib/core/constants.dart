class ApiConstants {
  // For Android Emulator, 10.0.2.2 points to your machine's localhost.
  // Based on your .env, JWT Issuer is https://localhost:7128.
  // We use 10.0.2.2 to access it from the emulator.
  static const String baseUrl = 'http://10.0.2.2:5003/api';
}
