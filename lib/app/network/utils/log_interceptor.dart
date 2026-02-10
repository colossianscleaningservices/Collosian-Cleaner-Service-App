import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/utils.dart';

import '../../utils/alerts.dart';

class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      printAll("-> [${options.method}] || ${options.uri}");

      var headerMsg = "HEADERS -> \n${const JsonEncoder.withIndent("    ").convert(options.headers)}";

      printAll(headerMsg);

      if (options.data != null) {
        printAll('REQUEST BODY ->');
        try {
          printAll(const JsonEncoder.withIndent("    ").convert(options.data));
        } catch (e) {
          printAll(options.data.toString());
        }
      }
    } catch (e) {
      e.printError;
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      log(runtimeType.toString(), "<- [${response.statusCode}] || ${response.realUri}");

      log(runtimeType.toString(), 'RESPONSE BODY ->');
      String body = "";

      try {
        body = const JsonEncoder.withIndent("  ").convert(response.data);
      } catch (e) {
        e.printError();
        body = response.data.toString();
      }

      printAll(body);
    } catch (e) {
      e.printError;
    }

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      log(runtimeType.toString(), "-> [${err.response?.statusCode}] || ${err.requestOptions.uri}");

      if (err.response?.data != null) {
        log(runtimeType.toString(), 'ERR BODY ->\n${err.response?.data}');
      }
    } catch (e) {
      e.printError;
    }

    return super.onError(err, handler);
  }

  void printAll(String msg) {
    msg.toString().split('\n').forEach((element) => log(runtimeType.toString(), element));
  }
}
