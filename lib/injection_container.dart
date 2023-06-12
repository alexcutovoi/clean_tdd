import 'package:clean_tdd/core/network/network_info.dart';
import 'package:clean_tdd/core/util/input_converter.dart';
import 'package:clean_tdd/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:clean_tdd/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:clean_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:clean_tdd/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

Future<void> init() async {
  //! Features - Number Trivia
  // Bloc
  GetIt.instance.registerFactory(() => NumberTriviaBloc(
    getConcreteNumberTrivia: GetIt.instance(),
    getRandomNumberTrivia: GetIt.instance(),
    inputConverter: GetIt.instance()
  ));

  // Use cases
  GetIt.instance.registerLazySingleton(() => GetConcreteNumberTrivia(GetIt.instance()));
  GetIt.instance.registerLazySingleton(() => GetRandomNumberTrivia(GetIt.instance()));

  // Repository
  GetIt.instance.registerLazySingleton<NumberTriviaRepository>(() => NumberTriviaRepositoryImpl(
    remoteDataSource: GetIt.instance(),
    localDataSource: GetIt.instance(),
    networkInfo: GetIt.instance()
  ));

  // Data sources. First one is the remote, second one is the local
  GetIt.instance.registerLazySingleton<NumberTriviaRemoteDataSource>(() => NumberTriviaRemoteDataSourceImpl(
    client: GetIt.instance()
  ));

  GetIt.instance.registerLazySingleton<NumberTriviaLocalDataSource>(() => NumberTriviaLocalDataSourceImpl(
    sharedPreferences: GetIt.instance()
  ));

  //! Core
  GetIt.instance.registerLazySingleton(() => InputConverter());
  GetIt.instance.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(
    GetIt.instance()
  ));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  GetIt.instance.registerLazySingleton(() => sharedPreferences);
  GetIt.instance.registerLazySingleton(() => Client());
  GetIt.instance.registerLazySingleton(() => DataConnectionChecker());
}