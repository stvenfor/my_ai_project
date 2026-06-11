import 'package:module_home/home_module.dart';
import 'package:module_route/module/module_standalone_config.dart';
import 'package:module_route/module/module_standalone_runner.dart';

Future<void> main() => ModuleStandaloneRunner.run(
      HomeModule(),
      config: const ModuleStandaloneConfig(
        injectMockUser: true,
        injectDefaultEnvironment: true,
      ),
    );
