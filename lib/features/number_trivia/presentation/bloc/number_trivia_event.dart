part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  final List<Object> numbers;
  const NumberTriviaEvent(this.numbers);

  @override
  List<Object> get props => numbers;
}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;

  GetTriviaForConcreteNumber(this.numberString) : super([numberString]);
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {
  GetTriviaForRandomNumber() : super([]);
}