// Spike S6: sembast_web (IndexedDB) with a large, append-heavy attempt history.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sembast_web/sembast_web.dart';

import 'spike_util.dart';

const _dbName = 'overtone_spike_s6';
final _store = intMapStoreFactory.store('attempts');
const _skills = 20;

Map<String, Object?> _attempt(int i) => {
  'id': 'a$i',
  'timestamp': DateTime.utc(
    2026,
    1,
    1,
  ).add(Duration(minutes: i)).toIso8601String(),
  'exerciseSetId': 'interval-recognition-basic',
  'questionId': 'q${i % 500}',
  'seed': i * 7919,
  'skillIds': ['skill-${i % _skills}', 'relative-pitch'],
  'skill': 'skill-${i % _skills}',
  'correct': i % 3 != 0,
  'responseMs': 800 + (i * 37) % 4000,
  'replays': i % 3,
  'hints': 0,
  'difficulty': 'beginner',
  'settingsHash': 'abcdef0123456789',
};

class S6StoragePage extends StatefulWidget {
  const S6StoragePage({super.key});

  @override
  State<S6StoragePage> createState() => _S6StoragePageState();
}

class _S6StoragePageState extends State<S6StoragePage> {
  final _log = <String>[];
  var _running = false;
  var _count = int.tryParse(Uri.base.queryParameters['n'] ?? '') ?? 50000;

  @override
  void initState() {
    super.initState();
    if (autoRun('S6')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  Future<T> _time<T>(
    String label,
    Future<T> Function() f,
    Map<String, Object?> out,
  ) async {
    final sw = Stopwatch()..start();
    final r = await f();
    sw.stop();
    out[label] = sw.elapsedMilliseconds;
    setState(() => _log.add('$label: ${sw.elapsedMilliseconds} ms'));
    return r;
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _log.clear();
    });
    final batch = int.tryParse(Uri.base.queryParameters['batch'] ?? '') ?? 1000;
    final out = <String, Object?>{'attempts': _count, 'batch': batch};
    try {
      var db = await _time(
        'open (empty)',
        () => databaseFactoryWeb.openDatabase(_dbName),
        out,
      );
      await _store.delete(db);

      await _time('insert $_count (batches of $batch)', () async {
        for (var start = 0; start < _count; start += batch) {
          await db.transaction((txn) async {
            await _store.addAll(txn, [
              for (var i = start; i < start + batch && i < _count; i++)
                _attempt(i),
            ]);
          });
        }
      }, out);

      await _time('200 single-attempt appends', () async {
        for (var i = 0; i < 200; i++) {
          await _store.add(db, _attempt(_count + i));
        }
      }, out);

      final bySkill = await _time(
        'query one skill',
        () => _store.find(
          db,
          finder: Finder(filter: Filter.equals('skill', 'skill-3')),
        ),
        out,
      );
      out['queryResults'] = bySkill.length;

      final json = await _time('export all to JSON', () async {
        final all = await _store.find(db);
        return jsonEncode({
          'format': 'overtone-progress',
          'formatVersion': 1,
          'attempts': [for (final r in all) r.value],
        });
      }, out);
      out['exportBytes'] = json.length;
      setState(
        () => _log.add(
          'export size: ${(json.length / 1024).toStringAsFixed(0)} KB',
        ),
      );

      await db.close();
      db = await _time(
        'reopen (load from IndexedDB)',
        () => databaseFactoryWeb.openDatabase(_dbName),
        out,
      );
      out['countAfterReopen'] = await _store.count(db);

      await _time('import (fresh DB + decode + insert)', () async {
        final decoded = jsonDecode(json) as Map<String, Object?>;
        final attempts = (decoded['attempts']! as List)
            .cast<Map<String, Object?>>();
        await db.close();
        await databaseFactoryWeb.deleteDatabase(_dbName);
        db = await databaseFactoryWeb.openDatabase(_dbName);
        for (var start = 0; start < attempts.length; start += batch) {
          await db.transaction((txn) async {
            await _store.addAll(txn, attempts.skip(start).take(batch).toList());
          });
        }
      }, out);
      out['countAfterImport'] = await _store.count(db);

      await db.close();
      await databaseFactoryWeb.deleteDatabase(_dbName);
      out['ok'] = true;
    } catch (e, s) {
      out['error'] = '$e';
      setState(() => _log.add('ERROR: $e\n$s'));
    } finally {
      publishResult('spikeS6', out);
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DropdownButton<int>(
                value: _count,
                items: const [
                  DropdownMenuItem(value: 5000, child: Text('5,000 attempts')),
                  DropdownMenuItem(
                    value: 50000,
                    child: Text('50,000 attempts'),
                  ),
                  DropdownMenuItem(
                    value: 200000,
                    child: Text('200,000 attempts'),
                  ),
                ],
                onChanged: _running ? null : (v) => setState(() => _count = v!),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _running ? null : _run,
                child: Text(_running ? 'Running...' : 'Run benchmark'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: ListView(children: [for (final l in _log) Text(l)])),
        ],
      ),
    );
  }
}
