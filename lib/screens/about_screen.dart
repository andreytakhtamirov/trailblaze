import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trailblaze/constants/about_constants.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/constants/pubspec.yaml.g.dart';
import 'package:trailblaze/util/firebase_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dependencies_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appName = 'Loading...';
  String _packageName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  void _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String? packageName = packageInfo.packageName;
    setState(() {
      _packageName = packageName;
      _appName = appName;
    });
  }

  void _openGitHubPage() async {
    UiHelper.openUri(kGithubUri);
  }

  void _openPrivacyPolicy() async {
    UiHelper.openUri(kPrivacyPolicyUri);
  }

  void _openTermsAndConditions() async {
    UiHelper.openUri(kTermsAndConditionsUri);
  }

  void _openEmailContact() async {
    await launchUrl(Uri.parse(Mailto(to: [kContactEmail]).toString()));
  }

  void _showDependenciesScreen() async {
    FirebaseHelper.logScreen("Dependencies");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DependenciesScreen(),
      ),
    );
  }

  Widget _clickableLink(String title, Function() onClick) {
    return InkWell(
      onTap: onClick,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image(
                            width: kDevicePixelRatio * 50,
                            fit: BoxFit.fill,
                            image: const AssetImage('assets/app_icon.jpg'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _appName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          version,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _packageName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      description,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _clickableLink(
                      'View on GitHub',
                      _openGitHubPage,
                    ),
                    const SizedBox(height: 12),
                    _clickableLink(
                      'Privacy Policy',
                      _openPrivacyPolicy,
                    ),
                    const SizedBox(height: 12),
                    _clickableLink(
                      'Terms and Conditions',
                      _openTermsAndConditions,
                    ),
                    const SizedBox(height: 12),
                    _clickableLink(
                      'Contact',
                      _openEmailContact,
                    ),
                    const SizedBox(height: 12),
                    _clickableLink(
                      'Dependencies',
                      _showDependenciesScreen,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Text(
                  kInfoFooter,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
