import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<ThemeBloc>(context),
      builder: (_, ThemeData theme) {
        return MaterialApp(
          title: 'Flutter Demo',
          home: CounterPage(),
          theme: theme,
        );
      },
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);
    final ThemeBloc _themeBloc = BlocProvider.of<ThemeBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: _counterBloc,
        builder: (BuildContext context, int count) {
          return Center(
            child: Text(
              '$count',
              key: Key('counter_text'),
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.decrement);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.update),
              onPressed: () {
                _themeBloc.dispatch(ThemeEvent.toggle);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  @override
  ThemeData get initialState => ThemeData.light();

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield currentState == ThemeData.dark()
            ? ThemeData.light()
            : ThemeData.dark();
        break;
    }
  }
}

void main() {
  group('BlocProviderTree', () {
    testWidgets('throws if initialized with no BlocProviders and no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          BlocProviderTree(
            blocProviders: null,
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no bloc',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          BlocProviderTree(
            blocProviders: null,
            child: Container(),
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          BlocProviderTree(
            blocProviders: [],
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes blocs to children', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProviderTree(
          blocProviders: [
            BlocProvider<CounterBloc>(builder: (context) => CounterBloc()),
            BlocProvider<ThemeBloc>(builder: (context) => ThemeBloc())
          ],
          child: MyApp(),
        ),
      );

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final Finder counterFinder = find.byKey((Key('counter_text')));
      expect(counterFinder, findsOneWidget);

      final Text counterText = tester.widget(counterFinder);
      expect(counterText.data, '0');
    });
  });
}
