import 'package:clean_tdd/core/use_cases/use_case.dart';
import 'package:clean_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_tdd/core/error/failures.dart';

class MockNumberTriviaRepository extends Mock
  implements NumberTriviaRepository{
    @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() =>
      super.noSuchMethod(Invocation.method(#getRandomNumberTrivia, []),
          returnValue: Future.value(
              const Right<Failure, NumberTrivia>(NumberTrivia(text: "", number: 1))));
  }

void main() {
  late GetRandomNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  late NumberTrivia numberTrivia;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
    numberTrivia = const NumberTrivia(text: 'test', number: 1);
  });

  test(
    'should get trivia from the repository',
    () async {
      when(mockNumberTriviaRepository.getRandomNumberTrivia()) 
        .thenAnswer((_) async => Right(numberTrivia));

      final result = await usecase(NoParams());

      expect(result, Right(numberTrivia));
      verify(mockNumberTriviaRepository.getRandomNumberTrivia());
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    }
  );
}