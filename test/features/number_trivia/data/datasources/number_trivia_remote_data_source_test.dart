import 'dart:convert';

import 'package:clean_tdd/core/error/exceptions.dart';
import 'package:clean_tdd/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:clean_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements Client {
  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
    super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}),
      returnValue: Future.value(Response(fixture('trivia.json'), 200)));
}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  const tNumber = 1;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMock200Response(Uri uri) {
    when(mockHttpClient.get(uri, headers: anyNamed('headers')))
      .thenAnswer((_) async => Response(fixture('trivia.json'), 200));
  }

  void setUpMock404Response(Uri uri) {
    when(mockHttpClient.get(uri, headers: anyNamed('headers')))
      .thenAnswer((_) async => Response('Something went wrong', 404));
  }

  group('Tests for concrete number trivia', () {
    final Uri uri = Uri(scheme: 'http', host: 'numbersapi.com', path: '$tNumber');
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should perform a GET request on a URL with number being the endpoint and with application/json header',
    () async {
      setUpMock200Response(uri);

      dataSource.getConcreteNumberTrivia(tNumber);
      verify(mockHttpClient.get(uri, headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200',
    () async {
      setUpMock200Response(uri);

      final result = await dataSource.getConcreteNumberTrivia(tNumber);

      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response code is not 200',
    () async {
      setUpMock404Response(uri);

      //Doing this way we return the function to the variable.
      final call = dataSource.getConcreteNumberTrivia;

      expect(() => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('Tests for random number trivia', () {
    final Uri uri = Uri(scheme: 'http', host: 'numbersapi.com', path: 'random');
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should perform a GET request on a URL with number being the endpoint and with application/json header',
    () async {
      setUpMock200Response(uri);

      dataSource.getRandomNumberTrivia();
      verify(mockHttpClient.get(uri, headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200',
    () async {
      setUpMock200Response(uri);

      final result = await dataSource.getRandomNumberTrivia();

      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response code is not 200',
    () async {
      setUpMock404Response(uri);

      //Doing this way we return the function to the variable.
      final call = dataSource.getRandomNumberTrivia;

      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}