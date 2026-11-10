import 'package:crypto/crypto.dart';

/// Short, stable content hash used for cache-busting query strings.
String contentHash(List<int> bytes) =>
    sha256.convert(bytes).toString().substring(0, 16);
