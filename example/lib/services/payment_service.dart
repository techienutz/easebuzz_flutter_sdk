import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easebuzz_flutter_sdk/easebuzz_flutter_sdk.dart';
import 'package:easebuzz_flutter_sdk/models/easebuzz_payment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class EaseBuzzPaymentRepository {
  static String key = kDebugMode ? "Test key" : "Production key";
  static String salt = kDebugMode ? "Test salt" : "Production salt";
  static final EasebuzzFlutterSdk _easebuzzFlutterPlugin = EasebuzzFlutterSdk();

  Future<void> initiatePayment({
    required String productName,
    required double amount,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final paymentModel = EasebuzzPaymentModel(
      txnid: "TEST${DateTime.now().millisecondsSinceEpoch}",
      amount: amount,
      productinfo: productName,
      firstname: "John",
      email: "john@example.com",
      phone: "9999999999",
      surl: "https://your-success-url.com",
      furl: "https://your-failure-url.com",
      splitPayments: jsonEncode({"Your_label": amount}),
      key: EaseBuzzPaymentRepository.key,
    );

    try {
      // Generate hash
      final hash = await _easebuzzFlutterPlugin.generateHash(
        paymentModel: paymentModel,
        key: EaseBuzzPaymentRepository.key,
        salt: EaseBuzzPaymentRepository.salt,
      );

      if (hash == null) {
        onError("Failed to generate hash.");
        return;
      }

      // Initiate payment link
      final response = kIsWeb
          ? await createAccessTokenForWeb(
              hash: hash, requestBody: paymentModel.toJson())
          : await _easebuzzFlutterPlugin.initiateLink(
              isTestMode: true, // Set to false for production
              hash: hash,
              paymentModel: paymentModel,
            );

      if (response == null) {
        onError("Failed to initiate payment link.");
        return;
      }

      // Proceed to payment
      final paymentResponse =
          await _easebuzzFlutterPlugin.payWithEasebuzz(response, "test");

      if (paymentResponse != null) {
        // Handle successful payment
        onSuccess("Payment successful: $paymentResponse");
      } else {
        // Handle failed payment
        onError("Payment failed: Payment response is null.");
      }
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      onError("Payment failed: ${e.message}");
    } catch (e) {
      // Handle general errors
      onError("Payment failed: ${e.toString()}");
    }
  }

  Future<String?> createAccessTokenForWeb(
      {required var requestBody, required String hash}) async {
    debugPrint("HASH : $hash");
    requestBody["hash"] = hash;
    debugPrint(requestBody.toString());

    try {
      final Dio dio = Dio();
      final response = await dio.post(
        "https://easebuzzaccesskey-fl7fm5v7ya-uc.a.run.app",
        data: {
          "requestBody": requestBody,
          "isTestMode": kDebugMode,
        },
      );
      log("Response: ${response.data}");
      // Handle success
      if (response.statusCode == 200 && response.data['status'] == 1) {
        debugPrint(
            "--------->  Payment Initiated Successfully: ${response.data?['data']}");

        return response.data?['data']?.toString();
      } else {
        debugPrint("Unexpected Response: ${response.statusCode}");
        debugPrint(response.data);
      }
    } on DioException catch (e) {
      // Handle error
      if (e.response != null) {
        debugPrint("Error Response: ${e.response?.data}");
        debugPrint("Status Code: ${e.response?.statusCode}");
      } else {
        debugPrint("Error: ${e.error}");
        debugPrint("Message: ${e.message}");
      }
    }
    return null;
  }
}
