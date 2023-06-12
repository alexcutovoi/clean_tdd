import 'dart:ffi';

import 'package:clean_tdd/core/error/exceptions.dart';
import 'package:clean_tdd/core/network/network_info.dart';
import 'package:clean_tdd/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:clean_tdd/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:clean_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_tdd/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock implements NumberTriviaRemoteDataSource {
  @override
    Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
        super.noSuchMethod(Invocation.method(#getConcreteNumberTrivia, [number]),
          returnValue: Future.value(
            const NumberTriviaModel(text: "", number: 1)));
  
  @override
    Future<NumberTriviaModel> getRandomNumberTrivia() =>
        super.noSuchMethod(Invocation.method(#getConcreteNumberTrivia, []),
          returnValue: Future.value(
            const NumberTriviaModel(text: "", number: 1)));
}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {
  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) =>
    super.noSuchMethod(Invocation.method(#cacheNumberTrivia, [triviaToCache]),
      returnValue: Future.value(Void));

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() =>
    super.noSuchMethod(Invocation.method(#getLastNumberTrivia, null),
      returnValue: Future.value(const NumberTriviaModel(number: 1, text: "")));
}

class MockNetworkInfo extends Mock implements NetworkInfo {
  @override
  Future<bool> get isConnected => super.noSuchMethod(
    Invocation.getter(#isConnected), returnValue: Future.value(true));
}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo
    );
  });

  void runTestsOnline(Function body) {
    group('Tests when device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('Tests when device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }
  
  group('Tests for concrete number trivia', () {
    const tNumber = 1;
    const tNumberTriviaModel = NumberTriviaModel(number: tNumber, text: 'test trivia');
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;
    
    test(
      'should check if device is online',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async {});
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);
        await repository.getConcreteNumberTrivia(tNumber);

        //This works because we called mockNetworkInfo.isConnected on getConcreteNumberTrivia
        verify(mockNetworkInfo.isConnected).called(1);
    });

    runTestsOnline(() {
      test('should return remote data when the call to remote data source is successful',
      () async {
        when(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async {});
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should cache the data locally when the call to reote data source is successful', () async {
        when(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async {});
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => tNumberTriviaModel);
        await repository.getConcreteNumberTrivia(tNumber);

        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });
    });

    test('should return server failure when the call to remote data source is unsuccessful',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenThrow(ServerException());
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });

    runTestsOffline(() {
      test('should return last locally cached data when it is present',
        () async {
          when(mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async  => tNumberTriviaModel);
          final result = await repository.getConcreteNumberTrivia(tNumber);
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, const Right(tNumberTrivia));
        });

        test('should return CacheFailure when there is no cached data present',
        () async {
          when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
          final result = await repository.getConcreteNumberTrivia(tNumber);
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result,equals(Left(CacheFailure())));
        });
    });
  });

  group('Tests for random number trivia', () {
    const tNumberTriviaModel = NumberTriviaModel(number: 123, text: 'test trivia');
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;
    
    test(
      'should check if device is online',
      () async {
        when(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async {});
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        await repository.getRandomNumberTrivia();

        //This works because we called mockNetworkInfo.isConnected on getConcreteNumberTrivia
        verify(mockNetworkInfo.isConnected).called(1);
    });

    runTestsOnline(() {
      test('should return remote data when the call to remote data source is successful',
      () async {
        when(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async {});
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getRandomNumberTrivia();
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should cache the data locally when the call to reote data source is successful', () async {
        when(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async {});
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        await repository.getRandomNumberTrivia();

        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });
    });

    test('should return server failure when the call to remote data source is unsuccessful',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenThrow(ServerException());
        final result = await repository.getRandomNumberTrivia();
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });

    runTestsOffline(() {
      test('should return last locally cached data when it is present',
        () async {
          when(mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async  => tNumberTriviaModel);
          final result = await repository.getRandomNumberTrivia();
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, const Right(tNumberTrivia));
        });

        test('should return CacheFailure when there is no cached data present',
        () async {
          when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
          final result = await repository.getRandomNumberTrivia();
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        });
    });
  });
} 