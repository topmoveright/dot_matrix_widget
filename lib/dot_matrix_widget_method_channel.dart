import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dot_matrix_widget_platform_interface.dart';

/// An implementation of [DotMatrixWidgetPlatform] that uses method channels.
class MethodChannelDotMatrixWidget extends DotMatrixWidgetPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dot_matrix_widget');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
