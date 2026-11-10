// Spike S5: how updates reach a returning browser.
// Fetches the content manifest (cache-busted by timestamp) and then a content
// file with ?v=<hash from the manifest>, and reports caching headers.
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'spike_util.dart';

class S5CachingPage extends StatefulWidget {
  const S5CachingPage({super.key});

  @override
  State<S5CachingPage> createState() => _S5CachingPageState();
}

class _S5CachingPageState extends State<S5CachingPage> {
  var _report = '';

  @override
  void initState() {
    super.initState();
    if (autoRun('S5')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  Future<Map<String, Object?>> _fetch(String url) async {
    final res = await web.window.fetch(url.toJS).toDart;
    final text = (await res.text().toDart).toDart;
    String? header(String n) => res.headers.get(n);
    return {
      'url': url,
      'status': res.status,
      'body': text.length > 200 ? '${text.substring(0, 200)}...' : text,
      'headers': {
        'cache-control': header('cache-control'),
        'age': header('age'),
        'etag': header('etag'),
        'last-modified': header('last-modified'),
        'x-cache': header('x-cache'),
        'x-served-by': header('x-served-by'),
      },
    };
  }

  Future<void> _run() async {
    final out = <String, Object?>{
      'baseUri': web.document.baseURI,
      'userAgent': web.window.navigator.userAgent,
      'appBuild': const String.fromEnvironment('APP_BUILD', defaultValue: '1'),
    };
    try {
      final regs =
          (await web.window.navigator.serviceWorker.getRegistrations().toDart)
              .toDart;
      out['serviceWorkerRegistrations'] = regs.length;
      out['serviceWorkerControlled'] =
          web.window.navigator.serviceWorker.controller != null;

      final manifest = await _fetch(
        'content/manifest.json?t=${DateTime.now().millisecondsSinceEpoch}',
      );
      out['manifest'] = manifest;
      final parsed =
          jsonDecode(manifest['body']! as String) as Map<String, Object?>;
      final hash = (parsed['files']! as Map<String, Object?>)['probe.txt'];
      out['probe'] = await _fetch('content/probe.txt?v=$hash');
    } catch (e) {
      out['error'] = '$e';
    }
    publishResult('spikeS5', out);
    setState(() => _report = const JsonEncoder.withIndent('  ').convert(out));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton(onPressed: _run, child: const Text('Fetch content now')),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(child: SelectableText(_report)),
          ),
        ],
      ),
    );
  }
}
