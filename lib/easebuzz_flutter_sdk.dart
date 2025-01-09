import 'easebuzz_flutter_sdk_platform_interface.dart';
import 'models/easebuzz_payment_model.dart';

class EasebuzzFlutterSdk {
  static final EasebuzzFlutterSdk _instance = EasebuzzFlutterSdk._internal();

  factory EasebuzzFlutterSdk() {
    return _instance;
  }

  EasebuzzFlutterSdk._internal();

  /// Initiates a payment through Easebuzz
  /// This method is supported on all platforms (Android, iOS, and Web)
  Future<Map<String, dynamic>?> payWithEasebuzz(
      String accessKey, String payMode,) {
    return EasebuzzFlutterSDKPlatform.instance
        .payWithEasebuzz(accessKey, payMode);
  }

  /// Generates a hash for the payment transaction
  Future<String?> generateHash({
    required EasebuzzPaymentModel paymentModel,
    required String key,
    required String salt,
  }) {
    return EasebuzzFlutterSDKPlatform.instance.generateHash(
      paymentModel: paymentModel,
      key: key,
      salt: salt,
    );
  }

  /// Initiates a payment link
  /// Note: This method is only available for Android and iOS platforms
  /// Throws UnsupportedError when called on Web platform
  Future<String?> initiateLink({
    required bool isTestMode,
    required String hash,
    required EasebuzzPaymentModel paymentModel,
  }) {
    return EasebuzzFlutterSDKPlatform.instance.initiateLink(
      isTestMode: isTestMode,
      hash: hash,
      paymentModel: paymentModel,
    );
  }
}
