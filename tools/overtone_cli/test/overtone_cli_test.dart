import 'package:overtone_cli/overtone_cli.dart';
import 'package:test/test.dart';

void main() {
  test('usage lists the content command group', () {
    expect(buildRunner().usage, contains('content'));
  });

  test('content usage lists validate, build, and new', () {
    final usage = buildRunner().commands['content']!.usage;
    expect(
      usage,
      allOf(contains('validate'), contains('build'), contains('new')),
    );
  });
}
