import 'package:clean_tdd/core/network/network_info.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {
  @override
  Future<bool> get hasConnection =>
    super.noSuchMethod(Invocation.method(#hasConnection, null),
      returnValue: Future.value(true));
}

void main() {
  late NetworkInfo networkInfo;
  late MockDataConnectionChecker mockDataConnectionChecker;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfo = NetworkInfoImpl(mockDataConnectionChecker);
  });

  group('is connected', () {
    test('should forward the call to DataConnectionChecker.hasConnection', 
    () async {
      final tHasConnectionFuture = Future.value(true);

      when(mockDataConnectionChecker.hasConnection).thenAnswer((_) async => tHasConnectionFuture);
      final result = networkInfo.isConnected;
      verify(mockDataConnectionChecker.hasConnection);
      expect(result, completes);
      expect(await result, true);
    });
  });
}

//LEAO123leao123