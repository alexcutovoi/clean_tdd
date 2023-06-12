import 'package:clean_tdd/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

//These two generic params are related to return type and function parameters
//First one (Type) represents the successful return from dartz (the right side of the Either object).
//The second one is about function parameters. An object can be of type Params.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable{
  @override
  List<Object?> get props => [];
}