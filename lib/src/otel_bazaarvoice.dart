// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_bazaarvoice_suppression.dart';

class BazaarvoiceResult {
  /// Creates a result.
  const BazaarvoiceResult({
    this.clientName,
    this.productId,
    this.reviewId,
    this.rating,
    this.authorId,
    this.contentType,
    this.moderationStatus,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? clientName;
  final String? productId;
  final String? reviewId;
  final int? rating;
  final String? authorId;
  final String? contentType;
  final String? moderationStatus;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class BazaarvoiceCallResult<T> {
  /// Creates a call result.
  const BazaarvoiceCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final BazaarvoiceResult? result;
}

Future<T> tracedBazaarvoice<T>({
  required String operation,
  required Future<BazaarvoiceCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (bazaarvoiceInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_bazaarvoice');
  final span = t.startSpan('bazaarvoice $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'bazaarvoice')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.clientName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('bazaarvoice.client', res.clientName!)]));
      }
      if (res.productId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('bazaarvoice.product.id', res.productId!)
        ]));
      }
      if (res.reviewId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('bazaarvoice.review.id', res.reviewId!)]));
      }
      if (res.rating != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('bazaarvoice.review.rating', res.rating!)]));
      }
      if (res.authorId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('bazaarvoice.author.id', res.authorId!)]));
      }
      if (res.contentType != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('bazaarvoice.content.type', res.contentType!)
        ]));
      }
      if (res.moderationStatus != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'bazaarvoice.moderation.status',
            res.moderationStatus!,
          )
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('bazaarvoice.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'bazaarvoice.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
