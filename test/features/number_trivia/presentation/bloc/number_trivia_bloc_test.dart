import 'package:clean_tdd/core/error/failures.dart';
import 'package:clean_tdd/core/use_cases/use_case.dart';
import 'package:clean_tdd/core/util/input_converter.dart';
import 'package:clean_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockNumberTriviaRepository extends Mock
  implements NumberTriviaRepository{
    @override
    Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int? number) =>
        super.noSuchMethod(Invocation.method(#getConcreteNumberTrivia, [number]),
            returnValue: Future.value(
                const Right<Failure, NumberTrivia>(NumberTrivia(text: "", number: 1))));
  }

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {
  @override
  final MockNumberTriviaRepository repository;

  MockGetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) =>
    super.noSuchMethod(Invocation.method(#call, [params]),
      returnValue: Future.value(
        const Right<Failure, NumberTrivia>(NumberTrivia(text: "", number: 1))));
}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {
  @override
  final MockNumberTriviaRepository repository;

  MockGetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) =>
    super.noSuchMethod(Invocation.method(#call, [params]),
      returnValue: Future.value(
        const Right<Failure, NumberTrivia>(NumberTrivia(text: "", number: 1))));
}

class MockInputConverter extends Mock implements InputConverter {
  @override
  Either<Failure, int> stringToUnsignedInteger(String str) =>
    super.noSuchMethod(Invocation.method(#stringToUnsignedInteger, [str]),
      returnValue: const Right<Failure, int>(1));
}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia(mockNumberTriviaRepository);
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia(mockNumberTriviaRepository);
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter);
  });

  test('Bloc Initial state should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('Tests for Concrete Trivia',() {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() => 
      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(const Right(tNumberParsed));

    test('should cal the InputConverter to validate and convert the string to an unsigned int',
    () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))).thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));

      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input in invalid',
    () async {
      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(Left(InvalidInputFailure()));

      expectLater(bloc.stream, emitsInOrder([
        Error(message: INVALID_INPUT_FAILURE_MESSAGE)
      ]));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case',
    () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))).thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      await mockGetConcreteNumberTrivia(const Params(number: tNumberParsed));

      verify(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully',
    () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))).thenAnswer((_) async => const Right(tNumberTrivia));

      await mockGetConcreteNumberTrivia(const Params(number: tNumberParsed));

      expectLater(bloc.stream, emitsInOrder([
        Loading(), Loaded(trivia: tNumberTrivia)
      ]));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] when getting data fails',
    () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))).thenAnswer((_) async => Left(ServerFailure()));

      expectLater(bloc.stream, emitsInOrder([
        Loading(), Error(message: SERVER_FAILURE_MESSAGE)
      ]));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] with a proper message for the error when getting data fails',
    () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))).thenAnswer((_) async => Left(CacheFailure()));

      expectLater(bloc.stream, emitsInOrder([
        Loading(), Error(message: CACHE_FAILURE_MESSAGE)
      ]));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('Tests for Random Trivia',() {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test('should get data from the random use case',
    () async {
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(GetTriviaForRandomNumber());

      await mockGetRandomNumberTrivia(NoParams());

      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully',
    () async {
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => const Right(tNumberTrivia));

      await mockGetRandomNumberTrivia(NoParams());

      expectLater(bloc.stream, emitsInOrder([
        Loading(), Loaded(trivia: tNumberTrivia)
      ]));

      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when getting data fails',
    () async {
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(ServerFailure()));

      expectLater(bloc.stream, emitsInOrder([
        Loading(), Error(message: SERVER_FAILURE_MESSAGE)
      ]));

      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] with a proper message for the error when getting data fails',
    () async {
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(CacheFailure()));

      expectLater(bloc.stream, emitsInOrder([
        Loading(), Error(message: CACHE_FAILURE_MESSAGE)
      ]));

      bloc.add(GetTriviaForRandomNumber());
    });
  });
}