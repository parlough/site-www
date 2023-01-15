---
title: Fetch data from the internet
description: Fetch data over the internet using the http package.
js: [{url: 'https://dartpad.dev/inject_embed.dart.js', defer: true}]
---

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

```dart
import 'package:http/http.dart' as http;
```

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

The following snippet creates a `Uri` object
pointing to the JSON-formatted information
about `package:http` from the [pub.dev site][].

```dart
Uri.parse('https://pub.dev/api/packages/http');
```

To learn about other ways of building and interacting with URIs,
see the [library tour's discussion about URIs][library-tour-uri].

[pub.dev site]: {{site.pub}}
[`Uri`]: {{site.dart-api}}/dart-core/Uri-class.html
[library-tour-uri]: /guides/libraries/library-tour#uris

## Make a network request

If you just need the body of the response,
you can use the top-level `read` function.

```dart
```

If you need other information from the response,
such as the `statusCode` or the `headers`,
you can instead use the top-level `get` function.

If the endpoint you are requesting from requires more information,
it often requires you to include [HTTP headers][].
You can specify headers by passing in a `Map<String, String>`
of the key-value pairs to the `headers` optional named parameter.

```dart
```

[HTTP headers]: https://developer.mozilla.org/docs/Web/HTTP/Headers

### Make multiple requests

If you're making multiple requests to the same server,
you can instead keep a persistent connection
through a `Client`,
and close it when done.

```dart
```

To enable the client to retry failed requests,
wrap your created `Client` in a `RetryClient`:

```dart
```

## Decode the retrieved data

Now that you have made a network request
and retrieved the returned data,
you can utilize that data.

### Create a class to store the data


```dart
class PackageVersion {
    final String name;

}
```

### Encode the data into your class

Now that you have a class to store your data in,
you need to add a mechanism to convert
the decoded JSON into your `PackageVersion` object.

Convert the decoded JSON
by manually writing writing a `fromJson` method
matching the earlier JSON format:

```dart
class PackageVersion {
    final String name;

}
```

A hand-written method, such as used here,
might be sufficient for relatively simple APIs,
but there other options.
To learn more about JSON serialization,
including automatic generation of JSON serialization logic,
see the [Using JSON][] guide.

### Convert the response to a `Package` object

To learn more about JSON and parsing it,
see the [Using JSON][] guide.

[Using JSON]: /guides/json

## Utilize the parsed data

Now that you've retrieved data and
converted it to a more easily accessible format,
you can use it however you'd like.
Some possibilities include
outputting information to a CLI, or
displaying it in a [web][] or [Flutter][] app.

Here is complete, runnable example
which requests, then displays information
about the latest `package:http` release
to the console:

```dart
void main() {

}

Future<PackageInfo> requestPackageInfo(String package, String version) async {

}

class PackageInfo {

}
```

[web]: /web
[Flutter]: {{site.flutter}}

## What next?

Now that you've retrieved and parsed the data,
you can do a lot more than just print it out.
One common use case is displaying the retrieved data
within a web or Flutter application.
To learn more about integrating retrieved data into a Flutter app,
see Flutter's [Fetching data from the internet][] documentation.

[Fetching data from the internet]: {{site.flutter-docs}}/cookbook/networking/fetch-data
