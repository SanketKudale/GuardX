class GuardXConfig {
  const GuardXConfig({
    this.logFileName = 'guardx_events.log',
    this.maxBreadcrumbs = 50,
    this.autoCaptureFlutterErrors = true,
    this.autoCapturePlatformErrors = true,
    this.markPlatformErrorsHandled = false,
  });

  final String logFileName;
  final int maxBreadcrumbs;
  final bool autoCaptureFlutterErrors;
  final bool autoCapturePlatformErrors;
  final bool markPlatformErrorsHandled;
}
