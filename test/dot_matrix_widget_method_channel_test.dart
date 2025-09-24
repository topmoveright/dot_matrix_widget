import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dot_matrix_widget/dot_matrix_widget_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDotMatrixWidget platform = MethodChannelDotMatrixWidget();
  const MethodChannel channel = MethodChannel('dot_matrix_widget');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
