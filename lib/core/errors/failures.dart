import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  // Solución: Convertido a súper-parámetro
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  // Solución: Convertido a súper-parámetro
  const CacheFailure(super.message);
}

class LocationFailure extends Failure {
  // Solución: Convertido a súper-parámetro
  const LocationFailure(super.message);
}

class PermissionFailure extends Failure {
  // Solución: Convertido a súper-parámetro
  const PermissionFailure(super.message);
}

class NetworkFailure extends Failure {
  // Solución: Convertido a súper-parámetro
  const NetworkFailure(super.message);
}