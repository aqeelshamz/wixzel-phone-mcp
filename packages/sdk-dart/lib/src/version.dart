/// The package version. Kept in step with pubspec.yaml by a test.
const String packageVersion = '0.1.0';

/// Sent as `User-Agent`.
const String userAgent = 'wixzel-phone/$packageVersion';

/// Sent as `X-Wixzel-Client`, which survives on Flutter web where the
/// browser overwrites `User-Agent`.
const String clientHeader = 'wixzel-phone-dart/$packageVersion';
