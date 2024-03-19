import 'package:flutter/material.dart';
import 'package:trailblaze/constants/about_constants.dart';
import 'package:trailblaze/constants/pubspec.yaml.g.dart';
import 'package:trailblaze/util/ui_helper.dart';

class DependenciesScreen extends StatelessWidget {
  const DependenciesScreen({super.key});

  void _openLicenseUrl(String dependency) async {
    UiHelper.openUri(Uri.parse('$kPackageHomeUrl/$dependency/$kLicensePath'));
  }

  void _openDependencyUrl(String dependency) async {
    UiHelper.openUri(Uri.parse('$kPackageHomeUrl/$dependency'));
  }

  @override
  Widget build(BuildContext context) {
    final allDependencies = <dynamic, dynamic>{};
    allDependencies.addAll(dependencies);
    allDependencies.addAll(devDependencies);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependencies'),
      ),
      body: ListView.builder(
        itemCount: allDependencies.length,
        itemBuilder: (context, index) {
          final dependency = allDependencies.keys.toList()[index];
          final version = allDependencies[dependency];

          return ListTile(
            title: InkWell(
                onTap: () => _openDependencyUrl(dependency),
                child: Text(dependency)),
            subtitle: Text('Version: $version'),
            trailing: InkWell(
              onTap: () => _openLicenseUrl(dependency),
              child: const Text(
                'License',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
