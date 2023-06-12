import 'package:clean_tdd/core/error/failures.dart';
import 'package:clean_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';

abstract class NumberTriviaRepository {
  //Either comes from dartz package. It's a functional programming package
  //that allows the user to return 2 objects: a failure and a success.
  //In our case, The Failure class represents the instances of failure object and NumberTrivia represents the success object.
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}