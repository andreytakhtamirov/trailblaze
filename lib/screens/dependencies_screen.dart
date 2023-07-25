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
    final dependencies = <dynamic, dynamic>{};
    dependencies.addAll(Pubspec.dependencies);
    dependencies.addAll(Pubspec.devDependencies);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependencies'),
      ),
      body: ListView.builder(
        itemCount: dependencies.length,
        itemBuilder: (context, index) {
          final dependency = dependencies.keys.toList()[index];
          final version = dependencies[dependency];

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
