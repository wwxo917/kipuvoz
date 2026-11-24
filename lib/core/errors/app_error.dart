import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Error propio de la app con un mensaje ya listo para el usuario.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

const sinConexion = 'No hay conexión. Revisa tu internet e intenta de nuevo.';

bool esErrorDeRed(Object error) {
  if (error is TimeoutException) return true;
  final tipo = error.runtimeType.toString();
  if (tipo.contains('ClientException') || tipo.contains('Retryable') ||
      tipo.contains('SocketException') || tipo.contains('NetworkException')) return true;
  final texto = error.toString();
  return texto.contains('SocketException') ||
      texto.contains('Failed host lookup') ||
      texto.contains('Network is unreachable') ||
      texto.contains('Connection refused') ||
      texto.contains('Connection closed') ||
      texto.contains('Failed to fetch') ||
      texto.contains('XMLHttpRequest error') ||
      texto.contains('NetworkError');
}

/// Convierte cualquier excepción en un mensaje claro, sin detalles técnicos.
String friendlyError(Object error) {
  if (error is AppException) return error.message;
  if (esErrorDeRed(error)) return sinConexion;

  if (error is AuthException) {
    final code = error.code ?? '';
    final msg = error.message.toLowerCase();
    if (code == 'invalid_credentials' || msg.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (code == 'user_already_exists' || msg.contains('already registered')) {
      return 'Este correo ya está registrado.';
    }
    if (code == 'email_not_confirmed' || msg.contains('not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión.';
    }
    if (code == 'weak_password' || msg.contains('password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (code == 'over_request_rate_limit' || code == 'over_email_send_rate_limit') {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    }
    return 'No se pudo completar la acción. Intenta de nuevo.';
  }

  if (error is PostgrestException) {
    switch (error.code) {
      case '23505':
        return error.message.contains('productos_nombre')
            ? 'Ya existe un producto activo con ese nombre.'
            : 'Este registro ya existe.';
      case '23514':
        return 'Hay un valor fuera de rango. Revisa los datos.';
      case '23502':
        return 'Falta un dato obligatorio.';
      case '22003':
        return 'El número ingresado es demasiado grande.';
      case '42501':
        return 'No tienes permiso para realizar esta acción.';
      case 'P0001':
        return error.message; // mensajes de la función (por ejemplo, stock insuficiente)
      case 'PGRST204':
        return 'Falta aplicar la migración 02 (categoría) en Supabase.';
      case '42P01':
      case 'PGRST205':
        return 'Faltan las tablas en Supabase. Ejecuta schema.sql en el SQL Editor.';
    }
    return 'No se pudo completar la acción. Intenta de nuevo.';
  }

  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
