// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_bazaarvoice/otel_bazaarvoice.dart';
import 'package:test/test.dart';

void main() {
  group('otel_bazaarvoice', () {
    test('suppression toggles in zone', () async {
      expect(bazaarvoiceInstrumentationSuppressed(), isFalse);
      await runWithoutBazaarvoiceInstrumentationAsync(() async {
        expect(bazaarvoiceInstrumentationSuppressed(), isTrue);
      });
      expect(bazaarvoiceInstrumentationSuppressed(), isFalse);
    });

    test('BazaarvoiceResult fields default null', () {
      const r = BazaarvoiceResult();
      expect(r.statusCode, isNull);
    });
  });
}
