import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/tabs/discover.dart';
import 'package:trailblaze/tabs/map.dart';
import 'package:trailblaze/tabs/profile/profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'managers/credential_manager.dart';
import 'managers/profile_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  MapboxOptions.setAccessToken(kMapboxAccessToken);
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
        colorScheme: const ColorScheme(
          primary: Color(0xFF255368),
          brightness: Brightness.light,
          onPrimary: Color(0xFFF3FBFF),
          secondary: Color(0xFFFF9800),
          onSecondary: Color(0xFF88B181),
          tertiary: Color(0xFF75A56C),
          onTertiary: Color(0xFFE8951B),
          error: Color(0xFFCE1515),
          onError: Color(0xFF000000),
          background: Color(0xFFFFFFFF),
          onBackground: Color(0xFF000000),
          surface: Color(0xFFF6FCFF),
          onSurface: Color(0xFF000000),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF255368),
          foregroundColor: Color(0xFFFFFFFF),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF6FCFF),
          selectedItemColor: Color(0xFF2AA4D7),
          unselectedItemColor: Color(0xFF66666B),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Color(0xFF75A56C),
          unselectedLabelColor: Color(0xFF98989D),
          indicatorColor: Color(0xFF75A56C),
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        // TODO textTheme
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
    const MapPage(),
    const DiscoverPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final credentials = await _loadCredentials();
      _refreshProfile(credentials);
    });
  }

  Future<Credentials?> _loadCredentials() async {
    final credentials = await CredentialManager().renewUserToken();
    ref.watch(credentialsProvider.notifier).setCredentials(credentials);
    return credentials;
  }

  Future<void> _refreshProfile(Credentials? credentials) async {
    final profile = await ProfileManager().refreshProfile(credentials);
    ref.watch(profileProvider.notifier).setProfile(profile);
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
            icon: Icon(Icons.route),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Discover',
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
