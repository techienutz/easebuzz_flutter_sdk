import 'package:flutter_test/flutter_test.dart';
import 'package:easebuzz_flutter_sdk/easebuzz_flutter_sdk.dart';
import 'package:easebuzz_flutter_sdk/easebuzz_flutter_sdk_platform_interface.dart';
import 'package:easebuzz_flutter_sdk/easebuzz_flutter_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEasebuzzFlutterSdkPlatform
    with MockPlatformInterfaceMixin
    implements EasebuzzFlutterSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EasebuzzFlutterSdkPlatform initialPlatform = EasebuzzFlutterSdkPlatform.instance;

  test('$MethodChannelEasebuzzFlutterSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEasebuzzFlutterSdk>());
  });

  test('getPlatformVersion', () async {
    EasebuzzFlutterSdk easebuzzFlutterSdkPlugin = EasebuzzFlutterSdk();
    MockEasebuzzFlutterSdkPlatform fakePlatform = MockEasebuzzFlutterSdkPlatform();
    EasebuzzFlutterSdkPlatform.instance = fakePlatform;

    expect(await easebuzzFlutterSdkPlugin.getPlatformVersion(), '42');
  });
}
