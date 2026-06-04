// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_bazaarvoice_suppression.dart';

class BazaarvoiceResult {
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

class BazaarvoiceCallResult<T> {
  const BazaarvoiceCallResult({required this.value, this.result});
  final T value;
  final BazaarvoiceResult? result;
}

Future<T> tracedBazaarvoice<T>({
  required String operation,
  required Future<BazaarvoiceCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (bazaarvoiceInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_bazaarvoice');
  final span = t.startSpan('bazaarvoice $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'bazaarvoice')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.clientName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bazaarvoice.client', res.clientName!)]));
      }
      if (res.productId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bazaarvoice.product.id', res.productId!)]));
      }
      if (res.reviewId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bazaarvoice.review.id', res.reviewId!)]));
      }
      if (res.rating != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('bazaarvoice.review.rating', res.rating!)]));
      }
      if (res.authorId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bazaarvoice.author.id', res.authorId!)]));
      }
      if (res.contentType != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('bazaarvoice.content.type', res.contentType!)
        ]));
      }
      if (res.moderationStatus != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            'bazaarvoice.moderation.status',
            res.moderationStatus!,
          )
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bazaarvoice.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
