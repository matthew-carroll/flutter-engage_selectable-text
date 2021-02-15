import 'package:flutter/material.dart';
import 'package:flutter_engage/demo_page.dart';
import 'package:flutter_engage/how_it_works_page.dart';
import 'package:flutter_engage/text_widget_page.dart';
import 'package:flutter_engage/the_goal_page.dart';

import 'material_selectable_text_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterEngageDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlutterEngageDemo extends StatefulWidget {
  @override
  _FlutterEngageDemoState createState() => _FlutterEngageDemoState();
}

class _FlutterEngageDemoState extends State<FlutterEngageDemo> {
  final _steps = <Step>[
    Step(
      title: 'SelectableText Widget',
      builder: (context) => MaterialSelectableTextPage(),
    ),
    Step(
      title: 'Text Widget',
      builder: (context) => TextWidgetPage(),
    ),
    Step(
      title: 'The Goal',
      builder: (context) => TheGoalPage(),
    ),
    Step(
      title: 'How Text Works',
      builder: (context) => HowItWorksPage(),
    ),
    Step(
      title: 'Build It!',
      builder: (context) {
        return Center(
          child: SizedBox(
            width: 800,
            child: DemoPage(),
          ),
        );
      },
    ),
  ];

  int _pageIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildStepMenu(),
          Container(
            width: 1,
            height: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 48),
            color: const Color(0xFFDDDDDD),
          ),
          Expanded(
            child: _steps[_pageIndex].builder(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepMenu() {
    return Center(
      child: Container(
        width: 325,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _steps.length; ++i) ...[
              _buildStepButton(
                index: i + 1,
                title: _steps[i].title,
                isSelected: _pageIndex == i,
                onPressed: _pageIndex != i
                    ? () {
                        setState(() {
                          _pageIndex = i;
                        });
                      }
                    : null,
              ),
              SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton({
    int index,
    String title,
    VoidCallback onPressed,
    bool isSelected = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: isSelected
              ? MaterialStateColor.resolveWith((states) => Colors.transparent)
              : MaterialStateColor.resolveWith(
                  (states) => const Color(0xFFEEEEEE)),
          foregroundColor: isSelected
              ? MaterialStateColor.resolveWith(
                  (states) => const Color(0xFFCCCCCC))
              : MaterialStateColor.resolveWith((states) => Colors.black),
        ),
        onPressed: onPressed,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$index - '
              '$title'),
        ),
      ),
    );
  }
}

class Step {
  const Step({
    @required this.title,
    @required this.builder,
  });

  final String title;
  final WidgetBuilder builder;
}
