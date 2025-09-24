import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dot_matrix_widget_method_channel.dart';

abstract class DotMatrixWidgetPlatform extends PlatformInterface {
  /// Constructs a DotMatrixWidgetPlatform.
  DotMatrixWidgetPlatform() : super(token: _token);

  static final Object _token = Object();

  static DotMatrixWidgetPlatform _instance = MethodChannelDotMatrixWidget();

  /// The default instance of [DotMatrixWidgetPlatform] to use.
  ///
  /// Defaults to [MethodChannelDotMatrixWidget].
  static DotMatrixWidgetPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DotMatrixWidgetPlatform] when
  /// they register themselves.
  static set instance(DotMatrixWidgetPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
