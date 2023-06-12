import 'package:clean_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    super.key,
  });

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final textEditingController = TextEditingController();
  String inputString = '';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        controller: textEditingController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Input a number'
        ),
        onChanged: (value) {
          inputString = value;
        },
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: ElevatedButton(
          onPressed: (){
            disptachConcrete();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: const Text('Search'),
        )),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton(
          onPressed: (){
            dispatchRandom();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: const Text('Get random trivia')
        )),
      ],)
    ],);
  }

  void disptachConcrete() {
    textEditingController.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
    .add(GetTriviaForConcreteNumber(inputString));
    inputString = '';
  }

  void dispatchRandom() {
    textEditingController.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
    .add(GetTriviaForRandomNumber());
    inputString = '';
  }
}