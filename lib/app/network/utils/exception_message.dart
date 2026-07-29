/// User-facing fallback messages for network/API errors (mirrors WAVTech).
class ExceptionMessage {
  const ExceptionMessage();

  String get badRequest => 'Sorry, the API request is invalid or improperly formed.';

  String get conflict => "Sorry, the request wasn't completed due to a conflict.";

  String get defaultError => 'Sorry, something went wrong.';

  String get emptyResponse => "Sorry, we couldn't receive a response from the server.";

  String get formatException => "Sorry, the request wasn't formatted correctly.";

  String get internalServerError => "Sorry, this isn't working right now. Please try again.";

  String get noInternetConnection => 'No internet connection.';

  String get notAcceptable => 'Sorry, the request is not acceptable.';

  String get notFound => "Sorry, the resource requested couldn't be found.";

  String get requestCancelled => 'Sorry, the request has been cancelled.';

  String get requestTimeout => 'Sorry, the request has timed out.';

  String get sendTimeout => 'Sorry, the request timed out while connecting to the server.';

  String get secureConnectionFailed => 'Secure connection failed. Please check your connection or try again later.';

  String get serviceUnavailable => 'Sorry, the service is unavailable.';

  String get unableToProcess => "Sorry, we couldn't process the data.";

  String get unauthorizedRequest => 'Sorry, the request is unauthorized.';

  String get forbiddenRequest => "Sorry, you don't have permission for this action.";

  String get unexpectedError => 'Something went wrong. Please try again.';
}
