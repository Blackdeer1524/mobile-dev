import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: WorkHomePage(),
    );
  }
}

class WorkItem {
  final String title;
  final WidgetBuilder builder;
  const WorkItem({required this.title, required this.builder});
}

// Works list (add more items as your portfolio grows)
final List<WorkItem> works = <WorkItem>[
  WorkItem(title: 'About This App', builder: (context) => const _AboutWork()),
  WorkItem(
    title: '[lab 1] ioControl [On/Off]',
    builder: (context) => const _IoControlWorkOnOff(),
  ),
  WorkItem(
    title: '[lab 2] ioControl',
    builder: (context) => const _IoControlWork(),
  ),
];

class WorkHomePage extends StatefulWidget {
  const WorkHomePage({Key? key}) : super(key: key);
  @override
  State<WorkHomePage> createState() => _WorkHomePageState();
}

class _WorkHomePageState extends State<WorkHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('My Programming Works'),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 700;
            if (isWide) {
              return Row(
                children: <Widget>[
                  SizedBox(
                    width: 280,
                    child: _WorkSelectionPanel(
                      selectedIndex: _selectedIndex,
                      onSelected: (i) => setState(() => _selectedIndex = i),
                    ),
                  ),
                  Container(width: 1, color: CupertinoColors.separator),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _WorkDetailView(
                        key: ValueKey<int>(_selectedIndex),
                        work: works[_selectedIndex],
                      ),
                    ),
                  ),
                ],
              );
            }
            return _WorkSelectionListCompact(
              onOpen: (index) {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => _WorkDetailScaffold(work: works[index]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _WorkSelectionPanel extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _WorkSelectionPanel({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: works.length,
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _SelectableTile(
              title: works[index].title,
              isSelected: isSelected,
              onTap: () => onSelected(index),
            ),
          );
        },
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const _SelectableTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isSelected
        ? CupertinoColors.activeBlue.withOpacity(0.12)
        : CupertinoColors.systemGroupedBackground;
    final Color fg = isSelected
        ? CupertinoColors.activeBlue
        : CupertinoColors.label;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.separator,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(CupertinoIcons.chevron_right, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

class _WorkDetailView extends StatelessWidget {
  final WorkItem work;
  const _WorkDetailView({Key? key, required this.work}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WorkDetailScaffold(work: work);
  }
}

class _WorkDetailScaffold extends StatelessWidget {
  final WorkItem work;
  const _WorkDetailScaffold({required this.work});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(work.title)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: work.builder(context),
        ),
      ),
    );
  }
}

class _WorkSelectionListCompact extends StatelessWidget {
  final ValueChanged<int> onOpen;
  const _WorkSelectionListCompact({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return CupertinoListTile(
            title: Text(works[index].title),
            trailing: const CupertinoListTileChevron(),
            onTap: () => onOpen(index),
          );
        },
        separatorBuilder: (context, _) => const SizedBox(
          height: 1,
          child: ColoredBox(color: CupertinoColors.separator),
        ),
        itemCount: works.length,
      ),
    );
  }
}

// ---- Demo work widgets ----

class _AboutWork extends StatelessWidget {
  const _AboutWork();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
          'Текст',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text('Мета-лаба - лаба для показа лаб'),
      ],
    );
  }
}

class _IoControlWorkOnOff extends StatefulWidget {
  const _IoControlWorkOnOff();
  @override
  State<_IoControlWorkOnOff> createState() => _IoControlWorkOnOffState();
}

class _IoControlWorkOnOffState extends State<_IoControlWorkOnOff> {
  int _isTurnedOn = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    try {
      final deviceUri = Uri.parse(
        'http://iocontrol.ru/api/readData/slesarevdaiu9/aaa',
      );
      final deviceRes = await http.get(deviceUri);
      final deviceJson = json.decode(deviceRes.body);
      final int isOn = int.parse(deviceJson['value'].toString());

      if (!mounted) return;
      setState(() {
        _isTurnedOn = isOn;
      });
    } catch (e) {
      print('Initial state load error: $e');
    }
  }

  Future<void> _getDeviceRequestON() async {
    try {
      final onUri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/1',
      );
      await http.get(onUri);
      setState(() {
        _isTurnedOn = 1;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Turn ON or read slider error: $e');
    }
  }

  Future<void> _getRequestOFF() async {
    if (_isTurnedOn == 0) return;
    try {
      final offUri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/0',
      );
      await http.get(offUri);
      setState(() {
        _isTurnedOn = 0;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Turn OFF error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Device Control (HTTP)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            (_isTurnedOn == 1)
                ? CupertinoButton.filled(
                    onPressed: _getDeviceRequestON,
                    child: const Text('ON'),
                  )
                : CupertinoButton(
                    onPressed: _getDeviceRequestON,
                    child: const Text('ON'),
                  ),
            const SizedBox(width: 12),
            (_isTurnedOn == 0)
                ? CupertinoButton.filled(
                    onPressed: _getRequestOFF,
                    child: const Text('OFF'),
                  )
                : CupertinoButton(
                    onPressed: _getRequestOFF,
                    child: const Text('OFF'),
                  ),
          ],
        ),
      ],
    );
  }
}

class _IoControlWork extends StatefulWidget {
  const _IoControlWork();
  @override
  State<_IoControlWork> createState() => _IoControlWorkState();
}

class _IoControlWorkState extends State<_IoControlWork> {
  int _isTurnedOn = 0;
  int _sliderValue = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    try {
      final deviceUri = Uri.parse(
        'http://iocontrol.ru/api/readData/slesarevdaiu9/aaa',
      );
      final deviceRes = await http.get(deviceUri);
      final deviceJson = json.decode(deviceRes.body);
      final int isOn = int.parse(deviceJson['value'].toString());

      final sliderUri = Uri.parse(
        'http://iocontrol.ru/api/readData/slesarevdaiu9/slider',
      );
      final sliderRes = await http.get(sliderUri);
      final sliderJson = json.decode(sliderRes.body);
      final int slider = int.parse(sliderJson['value'].toString());

      if (!mounted) return;
      setState(() {
        _isTurnedOn = isOn;
        _sliderValue = slider;
      });
    } catch (e) {
      print('Initial state load error: $e');
    }
  }

  Future<void> _getDeviceRequestON() async {
    try {
      final onUri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/1',
      );
      await http.get(onUri);
      setState(() {
        _isTurnedOn = 1;
      });
      final readSlider = Uri.parse(
        'http://iocontrol.ru/api/readData/slesarevdaiu9/slider',
      );
      final sliderRes = await http.get(readSlider);
      final jsonData = json.decode(sliderRes.body);
      setState(() {
        _sliderValue = int.parse(jsonData['value'].toString());
      });
    } catch (e) {
      // ignore: avoid_print
      print('Turn ON or read slider error: $e');
    }
  }

  Future<void> _getRequestOFF() async {
    if (_isTurnedOn == 0) return;
    try {
      final offUri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/aaa/0',
      );
      await http.get(offUri);
      setState(() {
        _isTurnedOn = 0;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Turn OFF error: $e');
    }
  }

  Future<void> _setSlider(int v) async {
    if (_isTurnedOn == 0) return;
    try {
      final uri = Uri.parse(
        'http://iocontrol.ru/api/sendData/slesarevdaiu9/slider/$v',
      );
      await http.get(uri);
      setState(() {
        _sliderValue = v;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Set slider error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Device Control (HTTP)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            (_isTurnedOn == 1)
                ? CupertinoButton.filled(
                    onPressed: _getDeviceRequestON,
                    child: const Text('ON'),
                  )
                : CupertinoButton(
                    onPressed: _getDeviceRequestON,
                    child: const Text('ON'),
                  ),
            const SizedBox(width: 12),
            (_isTurnedOn == 0)
                ? CupertinoButton.filled(
                    onPressed: _getRequestOFF,
                    child: const Text('OFF'),
                  )
                : CupertinoButton(
                    onPressed: _getRequestOFF,
                    child: const Text('OFF'),
                  ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            CupertinoButton(
              onPressed: () => _setSlider(0),
              child: const Text('reset'),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              onPressed: () => _setSlider(_sliderValue + 10),
              child: const Text('+'),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              onPressed: () => _setSlider(_sliderValue - 10),
              child: const Text('-'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: CupertinoSlider(
                value: _sliderValue.toDouble(),
                min: 0,
                max: 100,
                onChanged: (v) => _setSlider(v.round()),
              ),
            ),
            SizedBox(
              width: 64,
              child: Text('$_sliderValue', textAlign: TextAlign.end),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('State: ${_isTurnedOn == 1 ? 'ON' : 'OFF'}'),
      ],
    );
  }
}
