import 'package:auth0_flutter/auth0_flutter.dart';

extension CredentialsExtension on Credentials {
  // Include userProfile map in the toMap() method
  Map<String, dynamic> toMapWithUserProfile() => {
        'idToken': idToken,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'scopes': scopes.toList(),
        'userProfile': user.toMapCustom(),
        'tokenType': tokenType,
      };
}

extension UserProfileExtension on UserProfile {
  Map<String, dynamic> toMapCustom() => {
        'sub': sub,
        'name': name,
        'given_name': givenName,
        'family_name': familyName,
        'middle_name': middleName,
        'nickname': nickname,
        'preferred_username': preferredUsername,
        'profile': profileUrl?.toString(),
        'picture': pictureUrl?.toString(),
        'website': websiteUrl?.toString(),
        'email': email,
        'email_verified': isEmailVerified,
        'gender': gender,
        'birthdate': birthdate,
        'zoneinfo': zoneinfo,
        'locale': locale,
        'phone_number': phoneNumber,
        'phone_number_verified': isPhoneNumberVerified,
        'address': address,
        'updated_at': updatedAt?.toIso8601String(),
        'custom_claims': customClaims,
      };
}
