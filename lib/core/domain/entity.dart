import 'package:equatable/equatable.dart';

/// Base class for all domain entities
/// Using Equatable for value equality
abstract class Entity extends Equatable {
  const Entity();
  
  @override
  List<Object?> get props => [];
}
