class FastApiEndpoints {
  // Base URL
  static const String fastApiBaseUrl = "https://fastapi.jyotishionline.com";

  // ---------------- AUTH ----------------
  static const String login = "$fastApiBaseUrl/api/v1/auth/login";
  static const String loginOtp = "$fastApiBaseUrl/api/v1/auth/login-otp";
  static const String sendMobileOtp = "$fastApiBaseUrl/api/v1/auth/send-otp";
  static const String verifyMobileOtp = "$fastApiBaseUrl/api/v1/auth/verify-otp";

  // ---------------- ASTROLOGER ----------------
  static const String createAstrologer = "$fastApiBaseUrl/api/v1/astrologers";
  static const String getAstrologers = "$fastApiBaseUrl/api/v1/astrologers";
  static const String getAstrologerById = "$fastApiBaseUrl/api/v1/astrologers/"; // + id
  static const String updateAstrologer = "$fastApiBaseUrl/api/v1/astrologers/";
  static const String editAstrolgerProfile = "$fastApiBaseUrl/api/v1/astro/astrologers/";
  // + id
  static const String deleteAstrologer = "$fastApiBaseUrl/api/v1/astrologers/"; // + id

  // ---------------- CUSTOMER / USER ----------------
  static const String customerDetails = "$fastApiBaseUrl/api/v1/customerdetails"; // + /userId

  // ---------------- SESSION / CALL REQUEST ----------------
  static const String createSession = "$fastApiBaseUrl/api/v1/create"; // POST: create session
  static String getAstrologerRequests(String astrologerId) =>
      "$fastApiBaseUrl/api/v1/astrologer/$astrologerId"; // GET: fetch requests
  static const String updateSessionStatus =
      "$fastApiBaseUrl/api/v1/session/update"; // PUT: update request status (accept/reject)
}
