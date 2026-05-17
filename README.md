# otel_bazaarvoice

Dartastic OpenTelemetry bridge for Bazaarvoice (reviews + UGC).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_bazaarvoice/otel_bazaarvoice.dart';

await tracedBazaarvoice<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return BazaarvoiceCallResult(value: r, result: BazaarvoiceResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutBazaarvoiceInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
