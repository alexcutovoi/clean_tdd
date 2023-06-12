import 'package:clean_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_tdd/core/error/failures.dart';

class MockNumberTriviaRepository extends Mock
  implements NumberTriviaRepository{
    @override
    Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int? number) =>
        super.noSuchMethod(Invocation.method(#getConcreteNumberTrivia, [number]),
            returnValue: Future.value(
                const Right<Failure, NumberTrivia>(NumberTrivia(text: "", number: 1))));
  }

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  const number = 1;
  const numberTrivia = NumberTrivia(text: 'test', number: 1);

  test(
    'should get trivia for the number from the repository',
    () async {
      when(mockNumberTriviaRepository.getConcreteNumberTrivia(any)) 
        .thenAnswer((_) async => const Right(numberTrivia));

      final result = await usecase(const Params(number: number));

      expect(result, const Right(numberTrivia));
      verify(mockNumberTriviaRepository.getConcreteNumberTrivia(number));
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    }
  );
}