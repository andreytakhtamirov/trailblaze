import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:trailblaze/constants/settings_constants.dart';
import 'package:trailblaze/data/app_settings.dart';
import 'package:trailblaze/data/list_item.dart';
import 'package:trailblaze/screens/about_screen.dart';
import 'package:trailblaze/util/firebase_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/list_items/mini_post_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final double kListItemWidth = 330;
  bool _isUnitsMetric = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isUnitsMetric = AppSettings.isMetric;
    });
  }

  void _onSetUnits(bool isMetric) {
    setState(() {
      _isUnitsMetric = isMetric;
      AppSettings.setIsMetric(isMetric);
    });
    UiHelper.showSnackBarSuccess(
      context,
      'Updated settings',
      margin: const EdgeInsets.only(
        bottom: 10,
        right: 40,
        left: 40,
      ),
    );
  }

  void _onAboutPressed() {
    FirebaseHelper.logScreen("About");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 64, bottom: 64),
                      child: _previewWidget(),
                    ),
                    _divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Distance Units',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    _onSetUnits(true);
                                  },
                                  color: _isUnitsMetric
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(15)),
                                  ),
                                  child: const Text(
                                    'Metric',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    _onSetUnits(false);
                                  },
                                  color: _isUnitsMetric
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(15)),
                                  ),
                                  child: const Text(
                                    'Imperial',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: MaterialButton(
                onPressed: () {
                  _onAboutPressed();
                },
                padding: const EdgeInsets.all(16),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                color: Colors.grey.shade200,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'About app',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.arrow_forward_ios_sharp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewWidget() {
    return ScrollLoopAutoScroll(
        scrollDirection: Axis.horizontal,
        delay: const Duration(),
        duration: const Duration(seconds: 1000),
        gap: 5,
        reverseScroll: false,
        duplicateChild: 25,
        enableScrollInput: true,
        delayAfterScrollInput: const Duration(seconds: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AbsorbPointer(
              child: SizedBox(
                width: kListItemWidth,
                child: MiniPostView(
                  item: PostListItem.fromJson(kSamplePostJson1),
                  onItemDeleted: (i) {},
                ),
              ),
            ),
            const SizedBox(width: 5),
            AbsorbPointer(
              child: SizedBox(
                width: kListItemWidth,
                child: MiniPostView(
                  item: PostListItem.fromJson(kSamplePostJson2),
                  onItemDeleted: (i) {},
                ),
              ),
            ),
          ],
        ));
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey.shade300,
    );
  }
}
