import 'dart:convert';

import 'package:clean_tdd/core/error/exceptions.dart';

import '../models/number_trivia_model.dart';
import 'package:http/http.dart';

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl extends NumberTriviaRemoteDataSource {
  final Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) {
    return _getTriviaFromUrl(Uri(scheme: 'http', host: 'numbersapi.com', path: '$number'));
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    return _getTriviaFromUrl(Uri(scheme: 'http', host: 'numbersapi.com', path: 'random'));
  }

  Future<NumberTriviaModel> _getTriviaFromUrl(Uri uri) async {
    final response = await client.get(
      uri,
      headers: {'Content-Type': 'application/json'
      }
    );
    if(response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}