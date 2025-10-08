class ApiConfig {
  // Base URL for the API

  static const String baseUrl = 'http://10.0.2.2:5204/api/v1';



  //Deployed backend endpoints

  // Authentication endpoints (IAM)
  static const String signUp = '$baseUrl/authentication/sign-up';
  static const String signIn = '$baseUrl/authentication/sign-in';
  static const String verifyCode = '$baseUrl/authentication/verify-code';


  // Administrator profile endpoints
  static const String adminProfiles = '$baseUrl/administrator-profiles';

  // Teacher Profile endpoints
  static const String teachersProfiles = '$baseUrl/teachers-profiles';

  // Classroom endpoints
  static const String classrooms = '$baseUrl/classrooms';

  // Shared Spaces endpoints
  static const String sharedSpaces = '$baseUrl/shared-area';

  // Meetings endpoints
  static const String meetings = '$baseUrl/meetings';

  // Resources endpoints
  static const String resources = '$classrooms/resources';

  // Reports endpoints
  static const String reports = '$baseUrl/reports';

  // Reservations endpoints
  static const String reservations = '$baseUrl/reservations';
}