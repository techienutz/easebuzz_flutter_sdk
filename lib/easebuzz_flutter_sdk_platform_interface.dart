import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'easebuzz_flutter_sdk_method_channel.dart';
import 'models/easebuzz_payment_model.dart';

abstract class EasebuzzFlutterSDKPlatform extends PlatformInterface {
  EasebuzzFlutterSDKPlatform() : super(token: _token);

  static final Object _token = Object();

  static EasebuzzFlutterSDKPlatform _instance =
      MethodChannelEasebuzzFlutterSDK();

  static EasebuzzFlutterSDKPlatform get instance => _instance;

  static set instance(EasebuzzFlutterSDKPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>?> payWithEasebuzz(
    String accessKey,
    String payMode,
  ) {
    throw UnimplementedError('payWithEasebuzz() has not been implemented.');
  }

  /// Generates a hash for the payment transaction
  /// This method is not supported on web platform
  Future<String?> generateHash({
    required EasebuzzPaymentModel paymentModel,
    required String key,
    required String salt,
  }) {
    throw UnimplementedError('generateHash() has not been implemented.');
  }

  Future<String?> initiateLink({
    required bool isTestMode,
    required String hash,
    required EasebuzzPaymentModel paymentModel,
  });
}
