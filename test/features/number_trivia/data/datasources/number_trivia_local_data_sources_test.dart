import 'dart:convert';

import 'package:clean_tdd/core/error/exceptions.dart';
import 'package:clean_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clean_tdd/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import '../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  @override
  Future<bool> setString(String key, String value) =>
    super.noSuchMethod(Invocation.method(#setString, [key, value]),
      returnValue: Future.value(true)); 
}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('Tests to get last number trivia', (){
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_cache.json'))
    );

    test('should return NumberTrivia from SharedPreferences when there is one in the cache', 
    () async {
      when(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA)).thenReturn(fixture('trivia_cache.json'));

      final result = await dataSource.getLastNumberTrivia();
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException when there is no cached value', 
    () async {
      when(mockSharedPreferences.getString('')).thenReturn(null);

      final call = dataSource.getLastNumberTrivia;
      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('Test to cache number trivia', () {
    const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test trivia');
    test('should call SharedPreferences to cache the data', () async {
      when(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, json.encode(tNumberTriviaModel.toJson()))).thenAnswer((_) => Future.value(true));
      
      await dataSource.cacheNumberTrivia(tNumberTriviaModel);

      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}