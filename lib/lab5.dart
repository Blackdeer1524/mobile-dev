import 'package:flutter/cupertino.dart';

class CloudComputer extends StatefulWidget {
  const CloudComputer({Key? key}) : super(key: key);

  @override
  State<CloudComputer> createState() => _CloudComputerState();
}

class _CloudComputerState extends State<CloudComputer> {
  final _aVarText = TextEditingController();
  final _bVarText = TextEditingController();

  double computedValue = 0.0;
  double sliderValue = 0;

  @override
  void initState() {
    super.initState();
    sliderValue = 42;
  }

  @override
  void dispose() {
    _aVarText.dispose();
    _bVarText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(computedValue.toString()),
            CupertinoTextField(controller: _aVarText, placeholder: '0.0'),
            CupertinoTextField(controller: _bVarText, placeholder: '0.0'),
            Row(
              children: [
                CupertinoButton.filled(
                  onPressed: () {
                    setState(() {
                      var aVal = double.tryParse(_aVarText.text) ?? 0.0;
                      var bVal = double.tryParse(_bVarText.text) ?? 0.0;

                      computedValue = aVal + bVal;
                    });
                  },
                  child: const Text('add'),
                ),
                CupertinoButton.filled(
                  onPressed: () {
                    setState(() {
                      var aVal = double.tryParse(_aVarText.text) ?? 0.0;
                      var bVal = double.tryParse(_bVarText.text) ?? 0.0;

                      computedValue = aVal - bVal;
                    });
                  },
                  child: const Text('sub'),
                ),
                CupertinoButton.filled(
                  onPressed: () {
                    setState(() {
                      var aVal = double.tryParse(_aVarText.text) ?? 0.0;
                      var bVal = double.tryParse(_bVarText.text) ?? 0.0;

                      computedValue = aVal * bVal;
                    });
                  },
                  child: const Text('mult'),
                ),
                CupertinoButton.filled(
                  onPressed: () {
                    setState(() {
                      var aVal = double.tryParse(_aVarText.text) ?? 0.0;
                      var bVal = double.tryParse(_bVarText.text) ?? 0.0;

                      computedValue = aVal / bVal;
                    });
                  },
                  child: const Text('div'),
                ),
              ],
            ),
            CupertinoSlider(
              value: sliderValue,
              onChanged: (newValue) {
                setState(() {
                  sliderValue = newValue;
                });
              },
              min: 0.0,
              max: 100.0,
            ),
          ],
        ),
      ),
    );
  }
}
