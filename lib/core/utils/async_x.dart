import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  /// Dato actual si existe (incluso mientras se recarga); null si aún no hay.
  T? get dataOrNull => hasValue ? requireValue : null;
}
