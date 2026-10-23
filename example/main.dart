// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_bazaarvoice/otel_bazaarvoice.dart';

/// Traces Bazaarvoice calls with OpenTelemetry.
///
/// `otel_bazaarvoice` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Bazaarvoice call in
/// [tracedBazaarvoice]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'bazaarvoice-example');

  // Traces a Bazaarvoice call.
  final bazaarvoiceId = await tracedBazaarvoice<String>(
    operation: 'create',
    invoke: () async {
      // Make the Bazaarvoice call here, then report what it returned.
      const id = 'bazaarvoice_8f3a2c';
      return const BazaarvoiceCallResult(
          value: id,
          result: BazaarvoiceResult(
              clientName: 'example',
              productId: 'product_8f3a2c',
              reviewId: 'review_8f3a2c',
              rating: 1,
              authorId: 'author_8f3a2c',
              contentType: 'standard',
              moderationStatus: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedBazaarvoice create returned $bazaarvoiceId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutBazaarvoiceInstrumentationAsync.
  await runWithoutBazaarvoiceInstrumentationAsync(
    () => tracedBazaarvoice<String>(
      operation: 'create',
      invoke: () async {
        const id = 'bazaarvoice_8f3a2c';
        return const BazaarvoiceCallResult(
            value: id,
            result: BazaarvoiceResult(
                clientName: 'example',
                productId: 'product_8f3a2c',
                reviewId: 'review_8f3a2c',
                rating: 1,
                authorId: 'author_8f3a2c',
                contentType: 'standard',
                moderationStatus: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
