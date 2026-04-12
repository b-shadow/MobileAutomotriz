import 'package:equatable/equatable.dart';

import '../error/result.dart';

/// Base class for all use cases in the domain layer.
///
/// [Type] is the return type of the use case.
/// [Params] is the input parameter type.
///
/// Example:
/// ```dart
/// class GetNotes extends UseCase<List<Note>, NoParams> {
///   @override
///   Future<Result<List<Note>>> call(NoParams params) async { ... }
/// }
/// ```
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Use this when a use case doesn't require any parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
