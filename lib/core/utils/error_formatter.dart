/// Utility class for formatting error messages to be user-friendly.
///
/// Converts technical exceptions (SocketException, DioException, etc.)
/// into messages that end users can understand.
class ErrorFormatter {
  /// Format an error into a user-friendly message.
  static String format(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network connectivity issues
    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('no address associated') ||
        errorString.contains('clientexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection reset') ||
        errorString.contains('connection closed') ||
        errorString.contains('no internet')) {
      return 'Unable to connect. Please check your internet connection.';
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('timed out') ||
        errorString.contains('timeoutexception')) {
      return 'Request timed out. Please try again.';
    }

    // SSL/TLS errors
    if (errorString.contains('handshakeexception') ||
        errorString.contains('certificate') ||
        errorString.contains('ssl') ||
        errorString.contains('tls')) {
      return 'Secure connection failed. Please try again later.';
    }

    // Dio specific errors
    if (errorString.contains('dioexception') ||
        errorString.contains('dio error')) {
      if (errorString.contains('connection')) {
        return 'Unable to connect. Please check your internet connection.';
      }
      if (errorString.contains('cancel')) {
        return 'Request was cancelled. Please try again.';
      }
      return 'Something went wrong. Please try again.';
    }

    // HTTP errors (but not user-facing messages from server)
    if (errorString.contains('http') &&
        (errorString.contains('exception') || errorString.contains('error'))) {
      return 'Unable to reach server. Please try again.';
    }

    // Server response format issues
    if (errorString.contains('formatexception') ||
        errorString.contains('invalid response')) {
      return 'Received an unexpected response. Please try again.';
    }

    // Status code errors
    if (errorString.contains('status 401')) {
      if (errorString.contains('login failed')) {
        return 'Invalid username or password.';
      }
      return 'Unauthorized. Please login again.';
    }

    if (errorString.contains('status 403')) {
      return 'You do not have permission to perform this action.';
    }

    if (errorString.contains('status 404')) {
      return 'Requested resource not found.';
    }

    if (errorString.contains('status 500')) {
      return 'Internal server error. Please try again later.';
    }

    if (errorString.contains('status 502') ||
        errorString.contains('status 503') ||
        errorString.contains('status 504')) {
      return 'Service unavailable. Please try again later.';
    }

    // Clean up the error message for display
    String cleanMessage = error.toString();

    // Remove common prefixes recursively
    while (cleanMessage.startsWith('Exception: ')) {
      cleanMessage = cleanMessage.substring('Exception: '.length);
    }
    cleanMessage = cleanMessage.replaceAll('Exception: ', '');

    // If the message still looks too technical, provide a generic message
    if (cleanMessage.contains('::') ||
        cleanMessage.contains('at 0x') ||
        cleanMessage.contains('errno') ||
        cleanMessage.contains('OS Error') ||
        cleanMessage.length > 100) {
      return 'Something went wrong. Please try again.';
    }

    return cleanMessage;
  }
}
