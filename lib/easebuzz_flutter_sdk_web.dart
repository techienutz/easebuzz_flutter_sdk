import 'dart:async';
import 'dart:html' as web;
import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'easebuzz_flutter_sdk_platform_interface.dart';
import 'models/easebuzz_payment_model.dart';

class EasebuzzFlutterSdkWeb extends EasebuzzFlutterSDKPlatform {
  EasebuzzFlutterSdkWeb();

  static void registerWith(Registrar registrar) {
    EasebuzzFlutterSDKPlatform.instance = EasebuzzFlutterSdkWeb();
  }

  @override
  Future<Map<String, dynamic>?> payWithEasebuzz(
      String accessKey, String payMode,) async {
    // Existing implementation
    final completer = Completer<Map<String, dynamic>?>();
    void onResponse(dynamic response) {
      try {
        final responseMap = jsObjectToMap(response);
        if (!completer.isCompleted) {
          completer.complete(responseMap);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError('Error parsing response: $e');
        }
      }
    }

    try {
      final easebuzzCheckout = callConstructor(
        getProperty(web.window, 'EasebuzzCheckout'),
        [accessKey, payMode],
      );

      final options = jsify({
        'access_key': accessKey,
        'onResponse': allowInterop(onResponse),
        'theme': '#123456',
      });

      callMethod(easebuzzCheckout, 'initiatePayment', [options]);
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError('Error initiating payment: $e');
      }
    }

    return completer.future;
  }

  @override
  Future<String?> generateHash({
    required EasebuzzPaymentModel paymentModel,
    required String key,
    required String salt,
  }) async {
    try {
      // Build the hash sequence
      String valueOrBlank(String? value) =>
          (value?.isNotEmpty ?? false) ? value! : '';
      final data =
          '$key|${paymentModel.txnid}|${paymentModel.amount}|${paymentModel.productinfo}|'
          '${paymentModel.firstname}|${paymentModel.email}|'
          '${valueOrBlank(paymentModel.udf1)}|${valueOrBlank(paymentModel.udf2)}|'
          '${valueOrBlank(paymentModel.udf3)}|${valueOrBlank(paymentModel.udf4)}|'
          '${valueOrBlank(paymentModel.udf5)}|${valueOrBlank(paymentModel.udf6)}|'
          '${valueOrBlank(paymentModel.udf7)}||'
          '||$salt';

      // Get CryptoJS from window object
      final cryptoJS = getProperty(web.window, 'CryptoJS');

      // Generate SHA-512 hash
      final hash = callMethod(cryptoJS, 'SHA512', [data]);

      // Convert to string
      final hashString = callMethod(hash, 'toString', []);

      return hashString;
    } catch (e) {
      debugPrint('Error generating hash on web: $e');
      return null;
    }
  }

  Map<String, dynamic> jsObjectToMap(Object jsObject) {
    final map = <String, dynamic>{};
    final keys = objectKeys(jsObject);
    for (final key in keys) {
      if (key is String) {
        map[key] = getProperty(jsObject, key);
      }
    }
    return map;
  }

  @override
  Future<String?> initiateLink({
    required bool isTestMode,
    required String hash,
    required EasebuzzPaymentModel paymentModel,
  }) async {
    throw UnsupportedError('initiateLink() is not supported on web platform');
  }
}
