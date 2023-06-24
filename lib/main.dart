import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/tabs/discover.dart';
import 'package:trailblaze/tabs/map.dart';
import 'package:trailblaze/tabs/profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'managers/credential_manager.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF255368,
          <int, Color>{
            50: Color(0xFF194356),
            100: Color(0xFF255368),
            200: Color(0xFF3D687E),
            300: Color(0xFF376075),
            400: Color(0xFF5A94B0),
            500: Color(0xFF72A5BD),
            600: Color(0xFF95B8C9),
            700: Color(0xFF9BB1BB),
            800: Color(0xFFC3D2DA),
            900: Color(0xFFE4EAEF),
          },
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const DiscoverPage(),
    const MapPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadCredentials();
    });
  }

  Future<void> _loadCredentials() async {
    final credentials = await ref.watch(credentialsFutureProvider.future);
    ref.watch(credentialsNotifierProvider.notifier).setCredentials(credentials);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
