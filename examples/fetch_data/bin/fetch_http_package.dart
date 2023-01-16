import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  final httpPackage = await getPackage('http');

  if (httpPackage == null) {
    print('Failed to retrieve information about the http package!');
    return;
  }

  print('Information about the http package:');
  print('Latest version: ${httpPackage.latestVersion}');
  print('Description: ${httpPackage.description}');
  print('Publisher: ${httpPackage.publisher}');

  final httpRepository = httpPackage.repository;
  if (httpRepository != null) {
    print('Repository: ${httpPackage.repository}');
  }
}

// #docregion get-package
Future<PackageInfo?> getPackage(String packageName) async {
  final packageUrl = Uri.https('dart.dev/f/packages', '/$packageName.json');
  final packageResponse = await http.get(packageUrl);

  // If the request didn't succeed, return null
  if (packageResponse.statusCode != 200) {
    return null;
  }

  final packageJson = json.decode(packageResponse.body) as Map<String, dynamic>;

  return PackageInfo.fromJson(packageJson);
}
// #enddocregion get-package

// #docregion package-info, from-json
class PackageInfo {
  // #enddocregion from-json
  final String name;
  final String latestVersion;
  final String description;
  final String publisher;
  final Uri? repository;

  PackageInfo({
    required this.name,
    required this.latestVersion,
    required this.description,
    required this.publisher,
    this.repository,
  });
  // #enddocregion package-info
  // #docregion from-json

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    final repository = json['repository'] as String?;

    return PackageInfo(
      name: json['name'] as String,
      latestVersion: json['latestVersion'] as String,
      description: json['description'] as String,
      publisher: json['publisher'] as String,
      repository: repository != null ? Uri.tryParse(repository) : null,
    );
  }
  // #docregion package-info
}
// #enddocregion package-info, from-json
