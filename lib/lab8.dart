import 'package:ditredi/ditredi.dart';
import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:math';

class HandLab extends StatefulWidget {
  const HandLab({Key? key}) : super(key: key);

  @override
  State<HandLab> createState() => _HandLabState();
}

class _HandLabState extends State<HandLab> {
  var fingerAngle = 0.0;
  var handXAxisDisplacement = 0.0;
  var handYAxisDisplacement = 0.0;

  var sphereXAxisDisplacement = 0.0;
  var sphereYAxisDisplacement = 0.0;
  var isGraspingSphere = false;
  final Future<List<Mesh3D>> sceneObjs = _generatePoints();

  bool _isNearSphere() {
    final dx = handXAxisDisplacement - sphereXAxisDisplacement;
    final dy = handYAxisDisplacement - sphereYAxisDisplacement;
    final distance = sqrt(dx * dx + dy * dy);
    return distance < 3.0;
  }

  void _updateHandPosition(double deltaX, double deltaY) {
    setState(() {
      if (fingerAngle == 12 && _isNearSphere()) {
        isGraspingSphere = true;
        sphereXAxisDisplacement += deltaX;
        sphereYAxisDisplacement += deltaY;
      } else if (fingerAngle == 0) {
        isGraspingSphere = false;
      }

      handXAxisDisplacement += deltaX;
      handYAxisDisplacement += deltaY;
    });
  }

  final _controller = DiTreDiController(
    rotationX: -45,
    rotationY: -45,
    light: vector.Vector3(-0.5, -0.5, 0.5),
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            FutureBuilder(
              future: sceneObjs,
              builder: (BuildContext context, AsyncSnapshot<List<Mesh3D>> snapshot) {
                List<Widget> children;
                if (snapshot.hasData) {
                  children = <Widget>[
                    Expanded(
                      child: DiTreDiDraggable(
                        controller: _controller,
                        child: DiTreDi(
                          figures: [
                            TransformModifier3D(
                              snapshot.data![0],
                              Matrix4.identity()
                                ..translate(
                                  handXAxisDisplacement,
                                  handYAxisDisplacement,
                                  0,
                                )
                                ..rotateX(-pi / 2),
                            ),
                            TransformModifier3D(
                              snapshot.data![1],
                              Matrix4.identity()
                                ..translate(
                                  handXAxisDisplacement,
                                  handYAxisDisplacement,
                                  0,
                                )
                                ..rotateX(-pi / 2)
                                ..translate(3.05, 1.15, 8.75)
                                ..translate(-0.2, -0.25, -2.2)
                                ..rotateX(-(fingerAngle * pi / 18))
                                ..translate(0.2, 0.25, 2.2),
                            ),
                            TransformModifier3D(
                              snapshot.data![2],
                              Matrix4.identity()
                                ..translate(
                                  handXAxisDisplacement,
                                  handYAxisDisplacement,
                                  0,
                                )
                                ..rotateX(-pi / 2)
                                ..translate(0.7, 0.0, 9.75)
                                ..translate(0.0, -0.5, -2.25)
                                ..rotateX(-(fingerAngle * pi / 18))
                                ..translate(0.0, 0.5, 2.25),
                            ),
                            TransformModifier3D(
                              snapshot.data![3],
                              Matrix4.identity()
                                ..translate(
                                  handXAxisDisplacement,
                                  handYAxisDisplacement,
                                  0,
                                )
                                ..rotateX(-pi / 2)
                                ..translate(-2.0, -0.56, 9.1)
                                ..translate(0.0, -0.25, -2.2)
                                ..rotateX(-(fingerAngle * pi / 18))
                                ..translate(0.0, 0.25, 2.2),
                            ),
                            TransformModifier3D(
                              snapshot.data![4],
                              Matrix4.identity()
                                ..translate(
                                  handXAxisDisplacement,
                                  handYAxisDisplacement,
                                  0,
                                )
                                ..rotateX(-pi / 2)
                                ..translate(-4.65, -1.0, 7.15)
                                ..translate(0.0, 0.0, -1.25)
                                ..rotateX(-(fingerAngle * pi / 18))
                                ..translate(0.0, 0.0, 1.25),
                            ),
                            TransformModifier3D(
                              snapshot.data![5],
                              Matrix4.identity()
                                ..translate(
                                  sphereXAxisDisplacement,
                                  sphereYAxisDisplacement,
                                  -2,
                                )
                                ..scaleByDouble(2, 2, 2, 1),
                            ),
                          ],
                          controller: _controller,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Drag to rotate. Scroll to zoom"),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CupertinoButton(
                              color: fingerAngle == 12
                                  ? CupertinoColors.destructiveRed
                                  : CupertinoColors.activeGreen,
                              onPressed: () {
                                setState(() {
                                  fingerAngle = fingerAngle == 12 ? 0.0 : 12.0;
                                  // If releasing, stop grasping sphere
                                  if (fingerAngle == 0) {
                                    isGraspingSphere = false;
                                  } else if (fingerAngle == 12 &&
                                      _isNearSphere()) {
                                    isGraspingSphere = true;
                                  }
                                });
                              },
                              child: Text(
                                fingerAngle == 12 ? 'Release' : 'Grab',
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (isGraspingSphere)
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemYellow,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Text(
                                "Grasping Sphere!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          const Text(
                            "Hand Position",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  CupertinoButton(
                                    color: CupertinoColors.activeBlue,
                                    onPressed: () {
                                      _updateHandPosition(0.5, 0.0);
                                    },
                                    child: const Text('→'),
                                  ),
                                  Text(
                                    "X: ${handXAxisDisplacement.toStringAsFixed(1)}",
                                  ),
                                  CupertinoButton(
                                    color: CupertinoColors.activeBlue,
                                    onPressed: () {
                                      _updateHandPosition(-0.5, 0.0);
                                    },
                                    child: const Text('←'),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  CupertinoButton(
                                    color: CupertinoColors.activeBlue,
                                    onPressed: () {
                                      _updateHandPosition(0.0, 0.5);
                                    },
                                    child: const Text('↑'),
                                  ),
                                  Text(
                                    "Y: ${handYAxisDisplacement.toStringAsFixed(1)}",
                                  ),
                                  CupertinoButton(
                                    color: CupertinoColors.activeBlue,
                                    onPressed: () {
                                      _updateHandPosition(0.0, -0.5);
                                    },
                                    child: const Text('↓'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ];
                } else {
                  children = <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Failed to load"),
                    ),
                  ];
                }
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<Mesh3D>> _generatePoints() async {
  return [
    Mesh3D(await ObjParser().loadFromResources("assets/hand/hand.obj")),
    Mesh3D(await ObjParser().loadFromResources("assets/hand/index.obj")),
    Mesh3D(await ObjParser().loadFromResources("assets/hand/middle.obj")),
    Mesh3D(await ObjParser().loadFromResources("assets/hand/ring.obj")),
    Mesh3D(await ObjParser().loadFromResources("assets/hand/pinky.obj")),
    Mesh3D(await ObjParser().loadFromResources("assets/Sphere.obj")),
  ];
}
