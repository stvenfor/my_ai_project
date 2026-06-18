import 'package:module_utils/module_utils.dart';

class ImTelemetry {
  void metric(String name, {Map<String, dynamic>? params}) {
    LogUtils.i('[ImTelemetry] metric=$name params=$params');
  }

  void error(String name, Object error, {Map<String, dynamic>? params}) {
    LogUtils.e('[ImTelemetry] error=$name params=$params', error);
  }
}
