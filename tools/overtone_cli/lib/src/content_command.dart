import 'dart:io';

import 'package:args/command_runner.dart';

class ContentCommand extends Command<int> {
  ContentCommand() {
    addSubcommand(_NotImplemented('validate', 'Validate the content vault.'));
    addSubcommand(
      _NotImplemented(
        'build',
        'Validate the vault and generate the manifest and index.',
      ),
    );
    addSubcommand(_NotImplemented('new', 'Scaffold a note from a template.'));
  }

  @override
  String get name => 'content';

  @override
  String get description => 'Work with the Overtone content vault.';
}

class _NotImplemented extends Command<int> {
  _NotImplemented(this.name, this.description);

  @override
  final String name;

  @override
  final String description;

  @override
  int run() {
    stderr.writeln('overtone content $name is not implemented yet.');
    return 70;
  }
}
