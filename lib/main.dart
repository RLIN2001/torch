import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Torch',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const FlashLightApp(),
    );
  }
}

class FlashLightApp extends StatefulWidget {
  const FlashLightApp({super.key});

  @override
  State<FlashLightApp> createState() => _FlashLightAppState();
}

class _FlashLightAppState extends State<FlashLightApp> {
  bool _isOn = false;
  double _dragPosition = 0.0;
  final double _maxDragDistance = 100.0;
  double _bulbSize = 200.0;
  static const double _minBulbSize = 100.0;
  static const double _maxBulbSize = 300.0;
  bool _showSideBar = false;

  final List<Color> _colors = [
    Colors.yellow,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];
  int _currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _turnOffLight();
    }
  }

  Future<void> _toggleLight() async {
    if (kIsWeb) {
      setState(() {
        _isOn = !_isOn;
      });
      return;
    }

    try {
      if (_isOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isOn = !_isOn;
      });
    } on Exception catch (e) {
      debugPrint("Impossible to control the flashlight: $e");
    }
  }

  Future<void> _turnOffLight() async {
    if (kIsWeb) return;

    try {
      await TorchLight.disableTorch();
      setState(() {
        _isOn = false;
      });
    } on Exception catch (e) {
      debugPrint("Impossible to turn off the flashlight: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    await _toggleLight();
                  },
                  icon: Icon(
                    Icons.lightbulb,
                    size: _bulbSize,
                    color:
                        _isOn ? _colors[_currentColorIndex] : Colors.grey[700],
                  ),
                ),
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _dragPosition += details.delta.dy;
                      _dragPosition =
                          _dragPosition.clamp(0.0, _maxDragDistance);

                      if (_isOn && _dragPosition >= _maxDragDistance * 0.8) {
                        _toggleLight();
                        _dragPosition = 0.0;
                      }
                    });
                  },
                  onVerticalDragEnd: (details) {
                    if (!_isOn) {
                      if (_dragPosition >= _maxDragDistance * 0.8) {
                        _toggleLight();
                      }
                    } else {
                      if (_dragPosition <= _maxDragDistance * 0.2) {
                        _toggleLight();
                      }
                    }
                    setState(() {
                      _dragPosition = _isOn ? _maxDragDistance : 0.0;
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Container(
                      width: 40,
                      height: _maxDragDistance + 20,
                      color: Colors.transparent,
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 4,
                              height: _dragPosition,
                              color: Colors.grey[400],
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _showSideBar ? 0 : -60,
            top: 0,
            bottom: 0,
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(-2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                            _colors.length,
                            (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _currentColorIndex = index;
                                        _showSideBar = false;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _colors[index],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _currentColorIndex == index
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                        const SizedBox(height: 20),
                        const Text(
                          'Size',
                          style: TextStyle(color: Colors.white70),
                        ),
                        RotatedBox(
                          quarterTurns: 3,
                          child: SizedBox(
                            width: 150,
                            child: Slider(
                              value: _bulbSize,
                              min: _minBulbSize,
                              max: _maxBulbSize,
                              activeColor: _colors[_currentColorIndex],
                              onChanged: (value) {
                                setState(() {
                                  _bulbSize = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _showSideBar = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_showSideBar
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showSideBar = true;
                });
              },
              backgroundColor: _colors[_currentColorIndex],
              child: Icon(
                Icons.palette,
                color: _colors[_currentColorIndex] == Colors.yellow
                    ? Colors.black
                    : Colors.white,
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _turnOffLight();
    }
    super.dispose();
  }
}
