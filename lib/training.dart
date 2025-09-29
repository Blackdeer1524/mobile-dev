import 'package:flutter/cupertino.dart';

class TrainingLabWidget extends StatelessWidget {
  const TrainingLabWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('First'),
        // backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: CupertinoButton.filled(
          child: const Text("press me"),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => CupertinoPageScaffold(
                  navigationBar: const CupertinoNavigationBar(
                    middle: Text("wow"),
                  ),
                  child: SafeArea(child: BackButton()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Text("back to lab selection"),
      onPressed: () {
        Navigator.of(context)
          ..pop()
          ..pop();
      },
    );
  }
}

class StatefullTrainWidget extends StatefulWidget {
  final String test;
  const StatefullTrainWidget({super.key, required this.test});

  @override
  State<StatefulWidget> createState() => _StatefullTrainWidgetState();
}

class _StatefullTrainWidgetState extends State<StatefullTrainWidget> {
  int c = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext build) {
    return CupertinoButton(
      onPressed: () {
        setState(() {
          c += 1;
        });
      },
      child: Text(widget.test + c.toString()),
    );
  }
}
