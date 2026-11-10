// Verifies workspace dependency directions (see Planning/PLAN.md section 2.1).
import 'dart:io';

import 'package:yaml/yaml.dart';

const _allowed = <String, Set<String>>{
  'music_domain': {},
  'overtone_content': {'music_domain'},
  'exercise_engine': {'music_domain'},
  'learner_model': {'exercise_engine'},
  'overtone_cli': {'overtone_content', 'exercise_engine'},
  'overtone_web': {
    'music_domain',
    'overtone_content',
    'exercise_engine',
    'learner_model',
  },
};

const _paths = <String, String>{
  'music_domain': 'packages/music_domain',
  'overtone_content': 'packages/overtone_content',
  'exercise_engine': 'packages/exercise_engine',
  'learner_model': 'packages/learner_model',
  'overtone_cli': 'tools/overtone_cli',
  'overtone_web': 'apps/overtone_web',
};

void main() {
  final errors = <String>[];
  for (final MapEntry(key: name, value: path) in _paths.entries) {
    final pubspec = loadYaml(File('$path/pubspec.yaml').readAsStringSync());
    final deps =
        ((pubspec as YamlMap)['dependencies'] as YamlMap?)?.keys
            .cast<String>()
            .toSet() ??
        <String>{};

    for (final dep in deps.intersection(_allowed.keys.toSet())) {
      if (!_allowed[name]!.contains(dep)) {
        errors.add('$name must not depend on $dep');
      }
    }
    if (name != 'overtone_web' && deps.contains('flutter')) {
      errors.add('$name must not depend on flutter');
    }
  }

  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('Dependency directions OK.');
}
