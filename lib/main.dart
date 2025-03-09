import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window_manager
  await windowManager.ensureInitialized();
  
  // Set window properties
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1024, 768),
    minimumSize: Size(800, 600),
    center: true,
    title: 'Simple Viewer',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions);
  await windowManager.show();
  
  runApp(const ProviderScope(child: SimpleViewerApp()));
}

class SimpleViewerApp extends StatefulWidget {
  const SimpleViewerApp({super.key});

  @override
  State<SimpleViewerApp> createState() => _SimpleViewerAppState();
}

class _SimpleViewerAppState extends State<SimpleViewerApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
