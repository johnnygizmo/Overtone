import 'dart:io';

import 'package:overtone_cli/overtone_cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runOvertone(arguments);
}
