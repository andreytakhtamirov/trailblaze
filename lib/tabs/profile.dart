import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/data/list_item.dart';
import 'package:trailblaze/requests/fetch_items.dart';
import 'package:trailblaze/requests/user_profile.dart';
import 'package:trailblaze/screens/create_profile_screen.dart';
import 'package:trailblaze/widgets/items_feed_widget.dart';

import '../constants/auth_constants.dart';
import '../managers/credential_manager.dart';
import '../util/ui_helper.dart';
import '../widgets/profile/login_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  late Auth0 _auth0;
  dynamic _userProfile;
  bool _accountSetupNeeded = false;

  @override
  void initState() {
    super.initState();
    _auth0 = Auth0(kAuth0Domain, kAuth0ClientId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final credentials = ref.watch(credentialsNotifierProvider);
    refreshProfile(credentials);
  }

  Future<void> refreshProfile(Credentials? credentials) async {
    _relogin(credentials);
  }

  void _mutateCredentials(Credentials? credentials) {
    ref.read(credentialsNotifierProvider.notifier).setCredentials(credentials);
  }

  void _onLoginPressed() async {
    final Credentials credentials;

    try {
      credentials =
          await _auth0.webAuthentication(scheme: kAuth0Scheme).login();
    } catch (e) {
      log('Authentication error: $e');
      return;
    }

    _storeCredentials(credentials);
  }

  void _storeCredentials(Credentials? credentials) {
    if (credentials == null) {
      _mutateCredentials(null);
    } else {
      _mutateCredentials(credentials);
    }
  }

  Future<void> _onLogoutPressed() async {
    try {
      await _auth0.webAuthentication(scheme: kAuth0Scheme).logout();
    } on WebAuthenticationException {
      // This exception occurs if user cancels the browser prompt to log out.
      // Let's assume that this means they don't want to log out.
      return;
    } catch (e) {
      log('Log out error: $e');
    }

    _storeCredentials(null);
  }

  void _relogin(Credentials? credentials) async {
    final response = await getProfile(credentials?.idToken ?? '');
    response.fold(
      (error) => {
        // User account requires setup (first sign-in).
        if (error == 204)
          {
            setState(() {
              _accountSetupNeeded = true;
            }),
          }
        else
          {
            UiHelper.showSnackBar(context, "An unknown error occurred."),
          }
      },
      (data) => {
        setState(() {
          _userProfile = data;
          _accountSetupNeeded = false;
        }),
      },
    );
  }

  void _onEditProfilePressed(Credentials? credentials) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProfileScreen(
          credentials: credentials,
          userProfile: _userProfile,
        ),
      ),
    );

    if (data == null) {
      return;
    }

    setState(() {
      _userProfile = data;
      _accountSetupNeeded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final credentials = ref.watch(credentialsNotifierProvider);
    ImageProvider? userPicture;

    if (_userProfile?['profile_picture'] != null) {
      Uint8List imageBytes = base64Decode(_userProfile?['profile_picture']);
      userPicture = MemoryImage(imageBytes);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              size: 28,
            ),
            itemBuilder: (BuildContext context) {
              final menuItems = [
                const PopupMenuItem(
                  value: 'about',
                  child: ListTile(
                    title: Text('About'),
                  ),
                ),
              ];

              if (credentials != null) {
                menuItems.add(
                  const PopupMenuItem(
                    value: 'edit_profile',
                    child: ListTile(
                      title: Text('Edit Profile'),
                    ),
                  ),
                );
                menuItems.add(
                  const PopupMenuItem(
                    value: 'log_out',
                    child: ListTile(
                      title: Text('Log Out'),
                    ),
                  ),
                );
              }

              return menuItems;
            },
            onSelected: (value) {
              if (value == 'log_out') {
                _onLogoutPressed();
              } else if (value == 'edit_profile') {
                _onEditProfilePressed(credentials);
              }
              if (value == 'about') {
                // TODO implement about screen
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Visibility(
          visible: credentials != null,
          replacement: LoginView(
            onLoginPressed: _onLoginPressed,
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => refreshProfile(credentials),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 16, 24, 16),
                                child: userPicture != null
                                    ? Image(
                                        width: 150,
                                        fit: BoxFit.fitWidth,
                                        image: userPicture,
                                      )
                                    : CachedNetworkImage(
                                        width: 150,
                                        fit: BoxFit.fitWidth,
                                        imageUrl: credentials?.user.pictureUrl
                                                .toString() ??
                                            '',
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 0),
                                        fadeInDuration:
                                            const Duration(milliseconds: 0),
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 48, 0, 48),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userProfile?['username'] ??
                                            credentials?.user.name ??
                                            '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        credentials?.user.email ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Center(
                      child: Visibility(
                        visible: _accountSetupNeeded,
                        child: MaterialButton(
                          onPressed: () => _onEditProfilePressed(credentials),
                          color: Colors.red,
                          shape: const StadiumBorder(),
                          child: const Text(
                            "Complete account setup",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(
                            icon: Icon(Icons.favorite_border,
                                color: Theme.of(context).primaryColor),
                          ),
                          Tab(
                            icon: Icon(
                              Icons.route_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            ItemsFeed(
                              LikedPostsApiService(),
                              PostListItem,
                              isMinified: true,
                              jwtToken: credentials?.idToken ?? '',
                              feedInfoText:
                                  "Posts you've liked will appear here.",
                            ),
                            ItemsFeed(
                              UserRoutesApiService(),
                              RouteListItem,
                              isMinified: true,
                              jwtToken: credentials?.idToken ?? '',
                              feedInfoText:
                                  "Routes you've created will appear here.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
