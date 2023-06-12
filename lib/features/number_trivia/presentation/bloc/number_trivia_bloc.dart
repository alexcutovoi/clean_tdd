// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:clean_tdd/core/error/failures.dart';
import 'package:clean_tdd/core/use_cases/use_case.dart';
import 'package:clean_tdd/core/util/input_converter.dart';
import 'package:clean_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

// ignore: constant_identifier_names
const String SERVER_FAILURE_MESSAGE = 'Server Failure';

// ignore: constant_identifier_names
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';

// ignore: constant_identifier_names
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter
  }) : super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async {
      if(event is GetTriviaForConcreteNumber){
        final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);

        await inputEither.fold(
          (failure) async => emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE)), 
          (integer) async {
            final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
            _eitherLoadedOrErrorState(failureOrTrivia, emit);
          });
      } else if(event is GetTriviaForRandomNumber) {
            final failureOrTrivia = await getRandomNumberTrivia(NoParams());
            _eitherLoadedOrErrorState(failureOrTrivia, emit);
        }
    });
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> failureOrTrivia, Emitter<NumberTriviaState> emit) {
    emit(Loading());
    failureOrTrivia.fold(
      (failure) => emit(Error(message: _mapFailureToString(failure))),
      (trivia) => emit(Loaded(trivia: trivia)));
  }

  String _mapFailureToString(Failure failure) {
    switch(failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
