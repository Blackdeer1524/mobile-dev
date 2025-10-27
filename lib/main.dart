import 'package:flutter/cupertino.dart';
import 'package:untitiled2/lab1.dart';
import 'package:untitiled2/lab2.dart';
import 'package:untitiled2/lab4.dart';
import 'package:untitiled2/lab4_demo.dart';
import 'package:untitiled2/lab5.dart';
import 'package:untitiled2/lab5_3.dart';
import 'package:untitiled2/lab6.dart';
import 'package:untitiled2/lab8.dart';
import 'package:untitiled2/mysql_auth_app.dart';
import 'package:untitiled2/mqtt.dart';

void main() {
  runApp(const LabsApp());
}

class LabsApp extends StatelessWidget {
  const LabsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: WorkHomePage(),
    );
  }
}

class LabItem {
  final String title;
  final WidgetBuilder builder;
  const LabItem({required this.title, required this.builder});
}

// Works list (add more items as your portfolio grows)
final List<LabItem> labs = <LabItem>[
  LabItem(title: 'About This App', builder: (context) => const _AboutWork()),
  LabItem(
    title: '[lab 1] ioControl [On/Off]',
    builder: (context) => const IoControlWorkOnOff(),
  ),
  LabItem(
    title: '[lab 2] ioControl',
    builder: (context) => const IoControlWork(),
  ),
  LabItem(
    title: '[lab 4] Animation Controller demo',
    builder: (context) => const AnimationControllerDemo(),
  ),
  LabItem(
    title: '[lab 4] Animation Controller',
    builder: (context) => const AnimationControllerWork(),
  ),
  LabItem(
    title: '[MySQL] Database Authorization App',
    builder: (context) => MySqlAuthApp(),
  ),
  LabItem(title: '[MQTT] Messaging App', builder: (context) => MqttApp()),
  LabItem(
    title: '[lab 5.2] WebSockets App',
    builder: (context) => CloudComputer(),
  ),
  LabItem(
    title: '[lab 5.3] WebSockets App',
    builder: (context) => IoControlWS(),
  ),
  LabItem(
    title: '[lab 6] MapKit',
    builder: (context) => ObjectsMapPage(
      dataUrl:
          'http://pstgu.yss.su/iu9/mobiledev/lab4_yandex_map/2023.php?x=var20',
    ),
  ),
  LabItem(
    title: '[lab 8] Hand Manipulation',
    builder: (context) => HandLab(),
  ),
];

class WorkHomePage extends StatefulWidget {
  const WorkHomePage({Key? key}) : super(key: key);
  @override
  State<WorkHomePage> createState() => _WorkHomePageState();
}

class _WorkHomePageState extends State<WorkHomePage> {
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
            return _WorkSelectionListCompact(
              onOpen: (index) {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => _WorkDetailScaffold(work: labs[index]),
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

class _WorkDetailScaffold extends StatelessWidget {
  final LabItem work;
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
            title: Text(labs[index].title),
            trailing: const CupertinoListTileChevron(),
            onTap: () => onOpen(index),
          );
        },
        separatorBuilder: (context, _) => const SizedBox(
          height: 1,
          child: ColoredBox(color: CupertinoColors.separator),
        ),
        itemCount: labs.length,
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
