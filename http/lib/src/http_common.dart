/// Parse any uri (String or Uri).
Uri parseUri(dynamic url) {
  Uri uri;
  if (url is Uri) {
    uri = url;
  } else {
    uri = Uri.parse(url.toString());
  }
  return uri;
}
