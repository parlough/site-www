---
title: Fetch data from the internet
description: Fetch data over the internet using the http package.
js: [{url: 'https://dartpad.dev/inject_embed.dart.js', defer: true}]
---

<?code-excerpt path-base="fetch_data"?>

{{site.why.learn}}
  * The basics of what HTTP requests and URIs are and what they are used for.
  * Making HTTP requests using `package:http`.
  * Decoding JSON strings into Dart objects with `dart:convert`.
  * Converting JSON objects into class-based structures.
{{site.why.end}}

## URIs and HTTP requests

### HTTP requests

### URIs

To make an HTTP request,
you need to provide a URI (Uniform Resource Identifier) for the resource.
A URI is a character string that uniquely identifies a resource.
A URL (Uniform Resource Locator) is a specific kind of URI
that also provides the location of the resource.
URLs for resources on the web contain three pieces of information:

* The scheme used for determining the protocol used (https)
* The hostname of the server (dart.dev)
* The path to the resource (/tutorials/server/fetch-data.html)

## Retrieve the necessary dependencies

You can directly use `dart:io` or `dart:html` to make HTTP requests,
however those libraries are platform dependent.
`package:http` provides a cross-platform library
for making composable HTTP requests,
with optional fine-grained control.

To add a dependency on `package:http`,
run the [`dart pub add`][] command
while specifying `http`:

```terminal
$ dart pub add http
```

To then use `package:http` in your code,
import it and optionally [specify a library prefix][]:

<?code-excerpt "lib/fetch_data.dart (http-import)"?>
```dart
import 'package:http/http.dart' as http;
```

To learn more specifics about `package:http`,
see its [page on the pub.dev site][http-pub]
and its [API documentation][http-docs].

[`dart pub add`]: /tools/pub/cmd/pub-add
[specify a library prefix]: /guides/language/language-tour#specifying-a-library-prefix

## Build a URL

As previously mentioned,
to make an HTTP request,
you first need a URL which identifies
the resource being requested
or endpoint being accessed.

In Dart, URLs are represented through [`Uri`][] objects.
There are many ways to build an `Uri`,
but due to its flexibility,
parsing a string with `Uri.parse` to
create one is a common solution.

The following snippet shows two ways
to create a `Uri` object
pointing to fake JSON-formatted information
about `package:http` hosted on this site:

<?code-excerpt "lib/fetch_data.dart (build-uris)"?>
```dart
// Parse the entire URI, including the scheme
Uri.parse('https://dart.dev/f/packages/http.json');

// Specifically create a URI with the https scheme
Uri.https('dart.dev/f/packages', '/http.json');
```

To learn about other ways of building and interacting with URIs,
see the [library tour's discussion about URIs][library-tour-uri].

[`Uri`]: {{site.dart-api}}/dart-core/Uri-class.html
[library-tour-uri]: /guides/libraries/library-tour#uris

## Make a network request

If you just need to quickly get a string representation
of a requested resource,
you can use the top-level [`read`][http-read]
function found in `package:http`.
The following example uses `read` to
retrieve the fake JSON-formatted information
about `package:http` as a string,
then prints it out:

<?code-excerpt "lib/fetch_data.dart (http-read)"?>
```dart
void readMain() async {
  final httpPackageUrl = Uri.https('dart.dev/f/packages', '/http.json');
  final httpPackageInfo = await http.read(httpPackageUrl);
  print(httpPackageInfo);
}
```

This results in the following JSON-formatted output,
which can also be seen in your browser at
[https://dart.dev/f/packages/http.json][fake-http-json].

```json
{
  "name": "http",
  "latestVersion": "0.13.5",
  "description": "A composable, multi-platform, Future-based API for HTTP requests.",
  "publisher": "dart.dev",
  "repository": "https://github.com/dart-lang/http"
}
```

{{site.alert.info}}
  Many methods in `package:http` access the network and
  perform potentially time-consuming operations,
  therefore they do so asynchronously and return a [`Future`][].
  If you haven't encountered futures yet,
  you can learn about them—as well as the `async` and `await` keywords—in the
  [asynchronous programming codelab](/codelabs/async-await).
{{site.alert.end}}

If you need other information from the response,
such as the [status code][] or the [headers][],
you can instead use the top-level [`get`][http-get] function
which returns a `Future` with a [`Response`][http-response]:

```dart
```

If the endpoint you are requesting from requires more information,
it often requires you to include [HTTP headers][headers].
You can specify headers by passing in a `Map<String, String>`
of the key-value pairs to the `headers` optional named parameter:

```dart
```

[http-read]: {{site.pub-api}}/http/latest/http/read.html
[fake-http-json]: /f/packages/http.json
[`Future`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-async/Future-class.html
[status code]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
[headers]: https://developer.mozilla.org/docs/Web/HTTP/Headers
[http-get]: {{site.pub-api}}/http/latest/http/get.html
[http-response]: {{site.pub-api}}/http/latest/http/Response-class.html

### Make multiple requests

If you're making multiple requests to the same server,
you can instead keep a persistent connection
through a [`Client`][http-client],
which has similar methods to the top-level ones,
and close it when done.

<?code-excerpt "lib/fetch_data.dart (http-client)" replace="/clientMain/main/g"?>
```dart
void main() async {
  final httpPackageUrl = Uri.https('dart.dev/f/packages', '/http.json');
  final client = http.Client();
  try {
    final httpPackageInfo = await client.read(httpPackageUrl);
    print(httpPackageInfo);
  } finally {
    client.close();
  }
}
```

To enable the client to retry failed requests,
import 'package:http/retry.dart' and
wrap your created `Client` in a [`RetryClient`][http-retry-client]:

<?code-excerpt "lib/fetch_data.dart (http-retry)" plaster="none" replace="/retryMain/main/g; /(i.*?retry.*)/[!$1!]/g; /(Retry.*?\)\))/[!$1!]/g"?>
```dart
import 'package:http/http.dart' as http;
[!import 'package:http/retry.dart';!]

void main() async {
  final httpPackageUrl = Uri.https('dart.dev/f/packages', '/http.json');
  final client = [!RetryClient(http.Client())!];
  try {
    final httpPackageInfo = await client.read(httpPackageUrl);
    print(httpPackageInfo);
  } finally {
    client.close();
  }
}
```

The `RetryClient` has a default behavior
for how many times to retry and how long between each request,
but its behavior can be modified through parameters
to the [`RetryClient()`][http-retry-client-cons]
or [`RetryClient.withDelays()`][http-retry-client-delay] constructors.

`package:http` has much more functionality and customization,
so make sure to check out its [page on the pub.dev site][http-pub]
and its [API documentation][http-docs].

[http-client]: {{site.pub-api}}/http/latest/http/Client-class.html
[http-retry-client]: {{site.pub-api}}/http/latest/retry/RetryClient-class.html
[http-retry-client-cons]: {{site.pub-api}}/http/latest/retry/RetryClient/RetryClient.html
[http-retry-client-delay]: {{site.pub-api}}/http/latest/retry/RetryClient/RetryClient.withDelays.html

## Decode the retrieved data

Now that you have made a network request
and retrieved the returned data,
you can utilize that data.

### Create a class to store the data

<?code-excerpt "bin/fetch_http_package.dart (package-info)" plaster="none"?>
```dart
class PackageInfo {
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
}
```

### Encode the data into your class

Now that you have a class to store your data in,
you need to add a mechanism to convert
the decoded JSON into your `PackageInfo` object.

Convert the decoded JSON
by manually writing a `fromJson` method
matching the earlier JSON format:

<?code-excerpt "bin/fetch_http_package.dart (from-json)"?>
```dart
class PackageInfo {
  // ···

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
}
```

A handwritten method, such as used here,
might be sufficient for relatively simple APIs,
but there other options.
To learn more about JSON serialization,
including automatic generation of JSON serialization logic,
see the [Using JSON][] guide.

### Convert the response to a `PackageInfo` object

To learn more about JSON and parsing it,
see the [Using JSON][] guide.

<?code-excerpt "bin/fetch_http_package.dart (get-package)"?>
```dart
Future<PackageInfo?> getPackage(String packageName) async {
  final packageUrl = Uri.https('dart.dev/f/packages', '/$packageName.json');
  final packageResponse = await http.get(packageUrl);

  if (packageResponse.statusCode == 200) {
    final packageJson =
        jsonDecode(packageResponse.body) as Map<String, dynamic>;

    return PackageInfo.fromJson(packageJson);
  } else {
    return null;
  }
}
```

[Using JSON]: /guides/json

## Utilize the parsed data

Now that you've retrieved data and
converted it to a more easily accessible format,
you can use it however you'd like.
Some possibilities include
outputting information to a CLI, or
displaying it in a [web][] or [Flutter][] app.

Here is complete, runnable example
which requests, then displays
the mock information about the `http` package:

<?code-excerpt "bin/fetch_http_package.dart"?>
```dart:run-dartpad:height-480px:ga_id-fetch-data-complete
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

Future<PackageInfo?> getPackage(String packageName) async {
  final packageUrl = Uri.https('dart.dev/f/packages', '/$packageName.json');
  final packageResponse = await http.get(packageUrl);

  if (packageResponse.statusCode == 200) {
    final packageJson =
        jsonDecode(packageResponse.body) as Map<String, dynamic>;

    return PackageInfo.fromJson(packageJson);
  } else {
    return null;
  }
}

class PackageInfo {
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
}
```

{{site.alert.flutter-note}}
  For another example that covers fetching then displaying data in Flutter,
  see the [Fetching data from the internet][] Flutter cookbook.
{{site.alert.end}}

[web]: /web
[Flutter]: {{site.flutter}}
[Fetching data from the internet]: {{site.flutter-docs}}/cookbook/networking/fetch-data

## What next?

Now that you have retrieved, parsed, and utilized
data from the internet,
consider learning more about [Concurrency in Dart][].
If your data is large and complex,
you can move retrieval and decoding
to another [isolate][] as a background worker
to prevent your interface from becoming unresponsive.

[Concurrency in Dart]: /guides/language/concurrency
[isolate]: /guides/language/concurrency#how-isolates-work

[http-pub]: https://pub.dev/packages/http
[http-docs]: https://pub.dev/documentation/http
