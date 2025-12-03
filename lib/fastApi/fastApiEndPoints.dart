class FastApiEndpoints {
  static const String fastApiBaseUrl = "https://fastapi.jyotishionline.com";

  // AUTH
  static const String login = "$fastApiBaseUrl/api/v1/auth/login";
  static const String loginOtp = "$fastApiBaseUrl/api/v1/auth/login-otp";
  static const String sendMobileOtp = "$fastApiBaseUrl/api/v1/auth/send-otp";
  static const String verifyMobileOtp =
      "$fastApiBaseUrl/api/v1/auth/verify-otp";

  // ASTROLOGER
  static const String createAstrologer = "$fastApiBaseUrl/api/v1/astrologers";
  static const String getAstrologers = "$fastApiBaseUrl/api/v1/astrologers";
  static const String getAstrologerById = "$fastApiBaseUrl/api/v1/astrologers/";
  static const String updateAstrologer = "$fastApiBaseUrl/api/v1/astrologers/";
  static const String editAstrolgerProfile =
      "$fastApiBaseUrl/api/v1/astro/astrologers/";
  static const String amountBalanceAstrologer =
      "$fastApiBaseUrl/api/v1/astrowallet/";
  static const String transactionHistory =
      "$fastApiBaseUrl/api/v1/wallet/transactions/astrologer/";
  static const String deleteAstrologer = "$fastApiBaseUrl/api/v1/astrologers/";

  // CUSTOMER
  static const String customerDetails =
      "$fastApiBaseUrl/api/v1/customerdetails";

  // SESSION / CHAT REQUESTS
  static const String createSession = "$fastApiBaseUrl/api/v1/create";
  static String getAstrologerRequests(String astrologerId) =>
      "$fastApiBaseUrl/api/v1/astrologer/$astrologerId";

  /// ✅ API to accept/decline session request
  static const String respondToRequest =
      "$fastApiBaseUrl/api/v1/session/update";

  // FCM for astrologer
  static const String registerFcmTokenUrl =
      "$fastApiBaseUrl/Astrologer_notification/register-token";

  static String chatHistoryOther(String participantId,
          {int page = 1, int size = 20}) =>
      "$fastApiBaseUrl/chat/history/$participantId?page=$page&size=$size";

      static const String startAgoraLive = "$fastApiBaseUrl/agora/live/start";
      static const String endAgoraLive   = "$fastApiBaseUrl/agora/live/end";
}
