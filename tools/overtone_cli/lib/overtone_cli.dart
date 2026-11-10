import 'dart:io';

import 'package:args/command_runner.dart';

import 'src/content_command.dart';

CommandRunner<int> buildRunner() =>
    CommandRunner<int>('overtone', 'Overtone command-line tools.')
      ..addCommand(ContentCommand());

/// Runs the CLI and returns the process exit code.
Future<int> runOvertone(List<String> arguments) async {
  try {
    return await buildRunner().run(arguments) ?? 0;
  } on UsageException catch (e) {
    stderr.writeln(e);
    return 64;
  }
}
