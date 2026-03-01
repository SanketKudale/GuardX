import 'package:flutter_test/flutter_test.dart';
import 'package:guardx/guardx.dart';

void main() {
  test('serializes and deserializes event model', () {
    final GuardXEvent event = GuardXEvent.fromError(
      error: StateError('boom'),
      stackTrace: StackTrace.fromString('#0 testFrame'),
      extraContext: <String, dynamic>{'route': '/checkout'},
    );
    final Map<String, dynamic> json = event.toJson();
    final GuardXEvent roundTrip = GuardXEvent.fromJson(json);

    expect(roundTrip.errorType, equals('StateError'));
    expect(roundTrip.message, contains('boom'));
    expect(roundTrip.groupingKey, contains('StateError'));
    expect(roundTrip.extraContext['route'], equals('/checkout'));
  });
}
