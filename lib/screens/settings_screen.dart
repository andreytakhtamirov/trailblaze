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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: _previewWidget(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ]),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.straighten_rounded,
                              size: 28,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Distance Units',
                              style: TextStyle(
                                fontSize: 18,
                               fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              minWidth: 100,
                              onPressed: () {
                                _onSetUnits(true);
                              },
                              padding: const EdgeInsets.all(8),
                              color: _isUnitsMetric
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(15)),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Metric',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'kilometers',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MaterialButton(
                              minWidth: 100,
                              onPressed: () {
                                _onSetUnits(false);
                              },
                              padding: const EdgeInsets.all(8),
                              color: _isUnitsMetric
                                  ? Colors.grey
                                  : Theme.of(context).colorScheme.primary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(15)),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Imperial',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'miles',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: MaterialButton(
                  onPressed: () {
                    _onAboutPressed();
                  },
                  padding: const EdgeInsets.all(16),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  color: Colors.grey.shade200,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 28,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'About App',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios_sharp),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
}
