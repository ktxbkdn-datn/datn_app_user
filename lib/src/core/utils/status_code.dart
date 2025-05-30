// lib/src/core/utils/status_codes.dart
class StatusCodes {
  // Admin Login
  static const ADMIN_LOGIN_SUCCESS = "ADMIN_LOGIN_200";
  static const ADMIN_LOGIN_INVALID_JSON = "ADMIN_LOGIN_400_INVALID_JSON";
  static const ADMIN_LOGIN_MISSING_FIELDS = "ADMIN_LOGIN_400_MISSING_FIELDS";
  static const ADMIN_LOGIN_INVALID_CREDENTIALS = "ADMIN_LOGIN_401";
  static const ADMIN_LOGIN_SERVER_ERROR = "ADMIN_LOGIN_500";

  // User Login
  static const USER_LOGIN_SUCCESS = "USER_LOGIN_200";
  static const USER_LOGIN_INVALID_JSON = "USER_LOGIN_400_INVALID_JSON";
  static const USER_LOGIN_MISSING_FIELDS = "USER_LOGIN_400_MISSING_FIELDS";
  static const USER_LOGIN_INVALID_EMAIL = "USER_LOGIN_400_INVALID_EMAIL";
  static const USER_LOGIN_INVALID_CREDENTIALS = "USER_LOGIN_401";
  static const USER_LOGIN_SERVER_ERROR = "USER_LOGIN_500";

  // Logout
  static const LOGOUT_SUCCESS = "LOGOUT_200";
  static const LOGOUT_INVALID_JSON = "LOGOUT_400_INVALID_JSON";
  static const LOGOUT_SERVER_ERROR = "LOGOUT_500";

  // Forgot Password
  static const FORGOT_PASSWORD_SUCCESS = "FORGOT_PASSWORD_200";
  static const FORGOT_PASSWORD_EMAIL_FAILED = "FORGOT_PASSWORD_201";
  static const FORGOT_PASSWORD_INVALID_JSON = "FORGOT_PASSWORD_400_INVALID_JSON";
  static const FORGOT_PASSWORD_MISSING_EMAIL = "FORGOT_PASSWORD_400_MISSING_EMAIL";
  static const FORGOT_PASSWORD_INVALID_EMAIL = "FORGOT_PASSWORD_400_INVALID_EMAIL";
  static const FORGOT_PASSWORD_USER_NOT_FOUND = "FORGOT_PASSWORD_404";
  static const FORGOT_PASSWORD_SERVER_ERROR = "FORGOT_PASSWORD_500";

  // Reset Password
  static const RESET_PASSWORD_SUCCESS = "RESET_PASSWORD_200";
  static const RESET_PASSWORD_INVALID_JSON = "RESET_PASSWORD_400_INVALID_JSON";
  static const RESET_PASSWORD_MISSING_FIELDS = "RESET_PASSWORD_400_MISSING_FIELDS";
  static const RESET_PASSWORD_INVALID_EMAIL = "RESET_PASSWORD_400_INVALID_EMAIL";
  static const RESET_PASSWORD_INVALID_CODE = "RESET_PASSWORD_400_INVALID_CODE";
  static const RESET_PASSWORD_CODE_EXPIRED = "RESET_PASSWORD_400_CODE_EXPIRED";
  static const RESET_PASSWORD_TOO_MANY_ATTEMPTS = "RESET_PASSWORD_400_TOO_MANY_ATTEMPTS";
  static const RESET_PASSWORD_INVALID_CODE_ATTEMPTS = "RESET_PASSWORD_400_INVALID_CODE_ATTEMPTS";
  static const RESET_PASSWORD_TOKEN_NOT_FOUND = "RESET_PASSWORD_400_TOKEN_NOT_FOUND";
  static const RESET_PASSWORD_SERVER_ERROR = "RESET_PASSWORD_500";
}

Map<String, Map<int, String>> endpointStatusCodeMap = {
  '/auth/admin/login': {
    200: StatusCodes.ADMIN_LOGIN_SUCCESS,
    400: StatusCodes.ADMIN_LOGIN_INVALID_JSON, // Will refine based on message
    401: StatusCodes.ADMIN_LOGIN_INVALID_CREDENTIALS,
    500: StatusCodes.ADMIN_LOGIN_SERVER_ERROR,
  },
  '/auth/user/login': {
    200: StatusCodes.USER_LOGIN_SUCCESS,
    400: StatusCodes.USER_LOGIN_INVALID_JSON, // Will refine based on message
    401: StatusCodes.USER_LOGIN_INVALID_CREDENTIALS,
    500: StatusCodes.USER_LOGIN_SERVER_ERROR,
  },
  '/auth/logout': {
    200: StatusCodes.LOGOUT_SUCCESS,
    400: StatusCodes.LOGOUT_INVALID_JSON,
    500: StatusCodes.LOGOUT_SERVER_ERROR,
  },
  '/auth/forgot-password': {
    200: StatusCodes.FORGOT_PASSWORD_SUCCESS,
    201: StatusCodes.FORGOT_PASSWORD_EMAIL_FAILED,
    400: StatusCodes.FORGOT_PASSWORD_INVALID_JSON, // Will refine based on message
    404: StatusCodes.FORGOT_PASSWORD_USER_NOT_FOUND,
    500: StatusCodes.FORGOT_PASSWORD_SERVER_ERROR,
  },
  '/auth/reset-password': {
    200: StatusCodes.RESET_PASSWORD_SUCCESS,
    400: StatusCodes.RESET_PASSWORD_INVALID_JSON, // Will refine based on message
    500: StatusCodes.RESET_PASSWORD_SERVER_ERROR,
  },
};

String getCodeForEndpoint(String endpoint, int statusCode, String message) {
  final baseCode = endpointStatusCodeMap[endpoint]?[statusCode] ?? "UNKNOWN_CODE";

  // Refine codes based on message for endpoints with multiple 400 errors
  if (endpoint == '/auth/admin/login' && statusCode == 400) {
    if (message == "Thiếu username hoặc mật khẩu") {
      return StatusCodes.ADMIN_LOGIN_MISSING_FIELDS;
    }
    return StatusCodes.ADMIN_LOGIN_INVALID_JSON;
  }

  if (endpoint == '/auth/user/login' && statusCode == 400) {
    if (message == "Yêu cầu nhập email") {
      return StatusCodes.USER_LOGIN_MISSING_FIELDS;
    }
    if (message == "Yêu cầu nhập mật khẩu") {
      return StatusCodes.USER_LOGIN_MISSING_FIELDS;
    }
    if (message == "Định dạng email không hợp lệ") {
      return StatusCodes.USER_LOGIN_INVALID_EMAIL;
    }
    return StatusCodes.USER_LOGIN_INVALID_JSON;
  }

  if (endpoint == '/auth/forgot-password' && statusCode == 400) {
    if (message == "Yêu cầu nhập email") {
      return StatusCodes.FORGOT_PASSWORD_MISSING_EMAIL;
    }
    if (message == "Định dạng email không hợp lệ") {
      return StatusCodes.FORGOT_PASSWORD_INVALID_EMAIL;
    }
    return StatusCodes.FORGOT_PASSWORD_INVALID_JSON;
  }

  if (endpoint == '/auth/reset-password' && statusCode == 400) {
    if (message == "Yêu cầu nhập email, mật khẩu mới và mã xác nhận") {
      return StatusCodes.RESET_PASSWORD_MISSING_FIELDS;
    }
    if (message == "Định dạng email không hợp lệ") {
      return StatusCodes.RESET_PASSWORD_INVALID_EMAIL;
    }
    if (message == "Mã xác nhận phải là chuỗi 6 chữ số") {
      return StatusCodes.RESET_PASSWORD_INVALID_CODE;
    }
    if (message == "Mã xác nhận đã hết hạn hoặc không hợp lệ") {
      return StatusCodes.RESET_PASSWORD_CODE_EXPIRED;
    }
    if (message == "Bạn đã nhập sai mã quá 3 lần. Vui lòng yêu cầu mã xác nhận mới") {
      return StatusCodes.RESET_PASSWORD_TOO_MANY_ATTEMPTS;
    }
    if (message.startsWith("Mã xác nhận không chính xác. Bạn còn") && message.endsWith("lần thử.")) {
      return StatusCodes.RESET_PASSWORD_INVALID_CODE_ATTEMPTS;
    }
    if (message == "Không tìm thấy tài khoản hoặc mã xác nhận không hợp lệ") {
      return StatusCodes.RESET_PASSWORD_TOKEN_NOT_FOUND;
    }
    return StatusCodes.RESET_PASSWORD_INVALID_JSON;
  }

  return baseCode;
}