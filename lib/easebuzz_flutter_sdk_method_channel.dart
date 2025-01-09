import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'easebuzz_flutter_sdk_platform_interface.dart';
import 'models/easebuzz_payment_model.dart';

class MethodChannelEasebuzzFlutterSDK extends EasebuzzFlutterSDKPlatform {
  static const MethodChannel _methodChannel = MethodChannel('easebuzz');

  @override
  Future<Map<String, dynamic>?> payWithEasebuzz(
      String accessKey, String payMode,) async {
    try {
       final requestParams = <String, dynamic>{
        'access_key': accessKey,
        'pay_mode': payMode,
      };

      final result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'payWithEasebuzz',
        requestParams,
      );

      return result?.cast<String, dynamic>();
    } catch (e) {
      debugPrint('Error during payment: $e');
      return null;
    }
  }

  @override
  Future<String?> generateHash({
    required EasebuzzPaymentModel paymentModel,
    required String key,
    required String salt,
  }) async {
    try {
      // Function to return blank for null or empty values
      String valueOrBlank(String? value) =>
          (value?.isNotEmpty ?? false) ? value! : '';

      // Build the hash sequence
      final data =
          '$key|${paymentModel.txnid}|${paymentModel.amount}|${paymentModel.productinfo}|'
          '${paymentModel.firstname}|${paymentModel.email}|'
          '${valueOrBlank(paymentModel.udf1)}|${valueOrBlank(paymentModel.udf2)}|'
          '${valueOrBlank(paymentModel.udf3)}|${valueOrBlank(paymentModel.udf4)}|'
          '${valueOrBlank(paymentModel.udf5)}|${valueOrBlank(paymentModel.udf6)}|'
          '${valueOrBlank(paymentModel.udf7)}||'
          '||$salt';

      // Generate the hash using SHA-512
      return sha512.convert(utf8.encode(data)).toString();
    } catch (e) {
      debugPrint('Error generating hash: $e');
      return null;
    }
  }

  @override
  Future<String?> initiateLink({
    required bool isTestMode,
    required String hash,
    required EasebuzzPaymentModel paymentModel,
  }) async {
    final url = isTestMode
        ? 'https://testpay.easebuzz.in/payment/initiateLink'
        : 'https://pay.easebuzz.in/payment/initiateLink';

    // Set the hash in the payment model
    paymentModel.hash = hash;
    final dio = Dio();
    try {
      // Make the POST request
      final response = await dio.post(
        url,
        data: paymentModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Return the 'data' field from the response
        return response.data['data'];
      } else {
        // Handle error response
        debugPrint('Error: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('Error initiating link: $e');
      return null;
    }
  }
}
