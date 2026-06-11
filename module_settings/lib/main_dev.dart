import 'package:module_route/module/module_standalone_config.dart';
import 'package:module_route/module/module_standalone_runner.dart';
import 'package:module_settings/settings_module.dart';

Future<void> main() => ModuleStandaloneRunner.run(
      SettingsModule(),
      config: const ModuleStandaloneConfig(
        injectMockUser: true,
        injectDefaultEnvironment: true,
      ),
    );
