// #docregion json-decode
import 'dart:convert';

// #docregion http-import,http-retry
import 'package:http/http.dart' as http;
// #enddocregion json-decode, http-import
import 'package:http/retry.dart';

// #enddocregion http-retry

void buildUris() {
  // #docregion build-uris
  // Parse the entire URI, including the scheme
  Uri.parse('https://dart.dev/f/packages/http.json');

  // Specifically create a URI with the https scheme
  Uri.https('dart.dev/f/packages', '/http.json');
  // #enddocregion build-uris
}

// #docregion http-read
void readMain() async {
  final httpPackageUrl = Uri.https('dart.dev/f/packages', '/http.json');
  final httpPackageInfo = await http.read(httpPackageUrl);
  print(httpPackageInfo);
}
// #enddocregion http-read

// #docregion json-decode

void decodeMain() async {
  final httpPackageUrl = Uri.https('dart.dev/f/packages', '/http.json');
  final httpPackageInfo = await http.read(httpPackageUrl);
  final httpPackageJson = json.decode(httpPackageInfo) as Map<String, dynamic>;
  print(httpPackageJson);
}
// #enddocregion json-decode

// #docregion http-client
void clientMain() async {
  final httpPackageUrl = Uri.https('dart.dev/f/packages', '/http.json');
  final client = http.Client();
  try {
    final httpPackageInfo = await client.read(httpPackageUrl);
    print(httpPackageInfo);
  } finally {
    client.close();
  }
}
// #enddocregion http-client

// #docregion http-retry
void retryMain() async {
  final httpPackageUrl = Uri.https('dart.dev/f/packages', '/http.json');
  final client = RetryClient(http.Client());
  try {
    final httpPackageInfo = await client.read(httpPackageUrl);
    print(httpPackageInfo);
  } finally {
    client.close();
  }
}
// #enddocregion http-retry
