import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    this.credentials,
    required this.onLogoutPressed,
    required this.onEditProfilePressed,
  });

  final Credentials? credentials;
  final void Function() onLogoutPressed;
  final void Function(Credentials?) onEditProfilePressed;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
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
          onLogoutPressed();
        } else if (value == 'edit_profile') {
          onEditProfilePressed(credentials);
        }
        if (value == 'about') {
          // TODO implement about screen
        }
      },
    );
  }
}
