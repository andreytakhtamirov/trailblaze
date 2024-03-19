/// GENERATED CODE - DO NOT MODIFY BY HAND

/// ***************************************************************************
/// *                            pubspec_generator                            * 
/// ***************************************************************************

/*
  
  MIT License
  
  Copyright (c) 2024 Plague Fox
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
   
 */

// The pubspec file:
// https://dart.dev/tools/pub/pubspec

// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: unnecessary_raw_strings
// ignore_for_file: use_raw_strings
// ignore_for_file: avoid_escaping_inner_quotes
// ignore_for_file: prefer_single_quotes

/// Current app version
const String version = r'1.3.0';

/// The major version number: "1" in "1.2.3".
const int major = 1;

/// The minor version number: "2" in "1.2.3".
const int minor = 3;

/// The patch version number: "3" in "1.2.3".
const int patch = 0;

/// The pre-release identifier: "foo" in "1.2.3-foo".
const List<String> pre = <String>[];

/// The build identifier: "foo" in "1.2.3+foo".
const List<String> build = <String>[];

/// Build date in Unix Time (in seconds)
const int timestamp = 1710815739;

/// Name [name]
const String name = r'trailblaze';

/// Description [description]
const String description = r'A route-planning app that finds the scenic way to get to places.';

/// Repository [repository]
const String repository = r'';

/// Issue tracker [issue_tracker]
const String issueTracker = r'';

/// Homepage [homepage]
const String homepage = r'https://github.com/andreytakhtamirov/trailblaze-flutter';

/// Documentation [documentation]
const String documentation = r'';

/// Publish to [publish_to]
const String publishTo = r'none';

/// Environment
const Map<String, String> environment = <String, String>{
  'sdk': '>=3.2.0',
};

/// Dependencies
const Map<String, Object> dependencies = <String, Object>{
  'mapbox_maps_flutter': r'^1.0.0',
  'auth0_flutter': r'^1.4.1',
  'mapbox_search': r'4.0.0-beta.1',
  'http': r'^0.13.5',
  'secure_dotenv': r'^1.0.0',
  'geolocator': r'^9.0.2',
  'polyline_codec': r'^0.1.6',
  'turf': r'^0.0.7',
  'infinite_scroll_pagination': r'^3.2.0',
  'syncfusion_flutter_charts': r'^21.2.8',
  'expandable': r'^5.0.1',
  'intl': r'^0.18.1',
  'cached_network_image': r'^3.2.3',
  'flutter_secure_storage': r'^8.0.0',
  'flutter_riverpod': r'^2.3.6',
  'image_picker': r'^1.0.0',
  'image_cropper': r'^4.0.1',
  'connectivity_plus': r'^4.0.1',
  'flutter_cache_manager': r'^3.3.1',
  'package_info_plus': r'^4.0.2',
  'url_launcher': r'^6.1.12',
  'mailto': r'^2.0.0',
  'sliding_up_panel': r'^2.0.0+1',
  'loading_animation_widget': r'^1.2.0+4',
  'flutter': <String, Object>{
    'sdk': r'flutter',
  },
  'cupertino_icons': r'^1.0.2',
  'dartz': r'^0.10.1',
  'firebase_core': r'^2.25.4',
  'firebase_analytics': r'^10.8.10',
};

/// Developer dependencies
const Map<String, Object> devDependencies = <String, Object>{
  'flutter_test': <String, Object>{
    'sdk': r'flutter',
  },
  'flutter_launcher_icons': r'^0.13.1',
  'build_runner': r'^2.4.6',
  'pubspec_generator': r'^3.0.1',
  'secure_dotenv_generator': r'^1.0.0',
  'flutter_lints': r'^2.0.0',
};

/// Dependency overrides
const Map<String, Object> dependencyOverrides = <String, Object>{};

/// Executables
const Map<String, Object> executables = <String, Object>{};

/// Source data from pubspec.yaml
const Map<String, Object> source = <String, Object>{
  'name': name,
  'description': description,
  'repository': repository,
  'issue_tracker': issueTracker,
  'homepage': homepage,
  'documentation': documentation,
  'publish_to': publishTo,
  'version': version,
  'environment': environment,
  'dependencies': dependencies,
  'dev_dependencies': devDependencies,
  'dependency_overrides': dependencyOverrides,
  'flutter': <String, Object>{
    'uses-material-design': true,
    'assets': <Object>[
      r'assets/app_icon.png',
      r'assets/app_icon.jpg',
      r'assets/location-puck.png',
      r'assets/location-pin.png',
      r'.env',
    ],
    'fonts': <Object>[
      <String, Object>{
        'family': r'TrailblazeIcons',
        'fonts': <Object>[
          <String, Object>{
            'asset': r'fonts/TrailblazeIcons.ttf',
          },
        ],
      },
    ],
  },
  'flutter_launcher_icons': <String, Object>{
    'android': true,
    'ios': true,
    'remove_alpha_ios': true,
    'adaptive_icon_background': r'#ffffff',
    'image_path': r'assets/app_icon.png',
    'min_sdk_android': 21,
  },
};
