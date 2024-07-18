import 'dart:async';
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:clean_spotify_connec/config/constants/api_endpoints.dart';
import 'package:clean_spotify_connec/core/failure/failure.dart';
import 'package:clean_spotify_connec/core/networking/http_service.dart';
import 'package:clean_spotify_connec/core/shared_pref/user_shared_prefs.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';

import 'dart:math';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

// Define a utility function to generate a random string
String generateRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}

final spotifyRemoteDatasourceProvider =
    Provider.autoDispose<SpotifyRemoteDataSource>(
  (ref) => SpotifyRemoteDataSource(
    dio: ref.read(httpServiceProvider),
    userSharedPrefs: ref.read(userSharedPrefsProvider),
    // spotifyViewModel: ref.read(spotifyViewModelProvider)
  ),
);

class SpotifyRemoteDataSource {
  final String client_id =
      "0d288bf6cb1b4ba585804b0f43bda245"; // Replace with your actual client id
  final String client_secret =
      "699d7155e53b47c3a9ffc4c27f7e9446"; // Replace with your actual client secret
  final String redirect_uri =
      "my.music.app://callback"; // Replace with your actual redirect uri
  final Dio dio;

  final UserSharedPrefs userSharedPrefs;
  // final SpotifyViewModel spotifyViewModel;

  StreamSubscription? _sub;
  SpotifyRemoteDataSource({
    required this.userSharedPrefs,
    required this.dio,
    // required this.spotifyViewModel
  });

  // Future<Either<Failure, bool>> authorizeUser() async {
  //   final Dio dio = Dio();

  //   try {
  //     Response response = await dio.get('http://192.168.251.64:5000/login');

  //     // Decode the response data to check for an error field
  //     if (response.data is Map<String, dynamic>) {
  //       Map<String, dynamic> responseData = response.data;
  //       print(responseData);
  //       if (responseData.containsKey('error')) {
  //         // Handle the error field
  //         return Left(Failure(error: responseData['error']));
  //       } else {
  //         //handle redirect url
  //         // Launch the authorization URL
  //         final authUrl = responseData['auth_url'];
  //         if (await canLaunchUrl(authUrl)) {
  //           await launchUrl(authUrl);
  //           _initUniLinks();
  //           return const Right(true);
  //         } else {
  //           return Left(Failure(error: 'Could not launch $authUrl'));
  //         }

  //         // userSharedPrefs.setAcessToken(responseData['access_token']);
  //         // // userSharedPrefs
  //         // //     .setExpiryDate(responseData['expires_in']['expires_in']);
  //         // return const Right(true);
  //       }
  //     } else {
  //       return Left(Failure(error: 'Invalid response format'));
  //     }
  //   } on DioException catch (e) {
  //     // Handle Dio errors separately
  //     if (e.response != null && e.response!.data is Map<String, dynamic>) {
  //       Map<String, dynamic> responseData = e.response!.data;

  //       if (responseData.containsKey('error')) {
  //         return Left(Failure(error: responseData['error']));
  //       }
  //     }
  //     return Left(Failure(error: e.message!));
  //   } catch (e) {
  //     // Handle any other type of error
  //     return Left(Failure(error: e.toString()));
  //   }
  // }

  Future<void> _initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.queryParameters['code'] != null) {
        String code = uri.queryParameters['code']!;
        await _getAuthToken(code);
      }
    }, onError: (err) {
      print('Error: $err');
    });
  }

  Future<void> _getAuthToken(String code) async {
    const url = 'http://192.168.251.64:5000/callback';
    try {
      final response = await dio.post(url, data: {'code': code});
      if (response.statusCode == 200) {
        final responseData = response.data;
        // Handle the access token and other response data
        print(responseData);
      } else {
        print('Failed to get access token');
      }
    } catch (e) {
      print('Failed to get access token: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

//link to the refrence code
//https://medium.com/@ssk_karna/spotify-api-in-flutter-ed8ebc8eba03
  Future<void> authorizeUser() async {
    try {
      AccessTokenResponse? accessToken;
      SpotifyOAuth2Client client = SpotifyOAuth2Client(
        customUriScheme: 'my.music.app',
        redirectUri: 'my.music.app://callback',
      );
      var authResp =
          await client.requestAuthorization(clientId: client_id, customParams: {
        'show_dialog': 'true'
      }, scopes: [
        'user-read-private',
        'user-read-playback-state',
        'user-modify-playback-state',
        'user-read-currently-playing',
        'user-read-email'
      ]);
      print(authResp);
      var authCode = authResp.code;

      accessToken = await client.requestAccessToken(
          code: authCode.toString(),
          clientId: client_id,
          clientSecret: client_secret);
      print(accessToken);

      // Save access token, refresh token, and expiry date
      await userSharedPrefs.setAcessToken(accessToken.accessToken!);
      await userSharedPrefs.setRefreshToken(accessToken.refreshToken!);
      await userSharedPrefs.setExpiryDate(accessToken.expirationDate!);

      // Global variables
    } catch (e) {
      print('Error: $e');
    }
  }

  // Future<void> authorizeUser() async {
  //   try {
  //     AccessTokenResponse? accessToken;
  //     SpotifyOAuth2Client client = SpotifyOAuth2Client(
  //       customUriScheme: 'my.music.app',
  //       redirectUri: 'my.music.app://callback',
  //     );
  //     var authResp =
  //         await client.requestAuthorization(clientId: client_id, customParams: {
  //       'show_dialog': 'true'
  //     }, scopes: [
  //       'user-read-private',
  //       'user-read-playback-state',
  //       'user-modify-playback-state',
  //       'user-read-currently-playing',
  //       'user-read-email'
  //     ]);

  //     var authCode = authResp.code;
  //     accessToken = await client.requestAccessToken(
  //         code: authCode.toString(),
  //         clientId: client_id,
  //         // httpClient: ,
  //         clientSecret: client_secret);

  //     print('Access Token: ${accessToken.accessToken}');
  //     print('Refresh Token: ${accessToken.refreshToken}');
  //     print('Expiration Date: ${accessToken.expirationDate}');

  //     await userSharedPrefs.setAcessToken(accessToken.accessToken!);
  //     await userSharedPrefs.setRefreshToken(accessToken.refreshToken!);
  //     await userSharedPrefs.setExpiryDate(accessToken.expirationDate!);

  //     String userId = await getUserId(accessToken.accessToken!);
  //     print('User ID: $userId');
  //     await userSharedPrefs.setUserId(userId);
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
  // Future<void> authorizeUser() async {
  //   try {
  //     AccessTokenResponse? accessToken;

  //     const callbackUrlScheme = 'my.music.app';

  //     final result = await FlutterWebAuth.authenticate(
  //         url:
  //             "https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=${client_id}&redirect_uri=appname://callback",
  //         callbackUrlScheme: callbackUrlScheme);
  //     final token = Uri.parse(result).queryParameters['code'];
  //     print(token);
  //     // Save access token, refresh token, and expiry date
  //     // await userSharedPrefs.setAcessToken(token.accessToken!);
  //     // await userSharedPrefs.setRefreshToken(accessToken.refreshToken!);
  //     // await userSharedPrefs.setExpiryDate(accessToken.expirationDate!);
  //     // // Fetch user ID from Spotify API
  //     // String userId = await getUserId(accessToken.accessToken!);
  //     // print('User ID: $userId');

  //     // // Save user ID using shared preferences or other storage
  //     // await userSharedPrefs.setUserId(userId);

  //     // Handle global variables or state updates as needed

  //     // Global variables
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  // Future<String> getUserId(String accessToken) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('https://api.spotify.com/v1/me'),
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       return data['id'];
  //     } else {
  //       print('Failed to get user ID: ${response.statusCode}');
  //       throw Exception('Failed to get user ID');
  //     }
  //   } catch (e) {
  //     print('Error getting user ID: $e');
  //     throw Exception('Failed to get user ID');
  //   }
  // }

  // Future<String> createPlaylist(String userId, String accessToken) async {
  //   final response = await http.post(
  //     Uri.parse('https://api.spotify.com/v1/users/$userId/playlists'),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode({
  //       'name': 'My New Playlist',
  //       'description': 'A new playlist created from Flutter app',
  //       'public': false
  //     }),
  //   );

  //   if (response.statusCode == 201) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     return data['id'];
  //   } else {
  //     throw Exception('Failed to create playlist');
  //   }
  // }

  // Future<void> addTracksToPlaylist(
  //     String playlistId, List<String> trackUris, String accessToken) async {
  //   final response = await http.post(
  //     Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode({
  //       'uris': trackUris,
  //     }),
  //   );

  //   if (response.statusCode != 201) {
  //     throw Exception('Failed to add tracks to playlist');
  //   }
  // }

  Future<Either<Failure, bool>> postPrompt(String prompt) async {
    try {
      final eitherToken = await userSharedPrefs.getAcessToken();

      return eitherToken.fold(
        (failure) {
          // Handle failure to retrieve access token
          print("Failed to retrieve access token: ${failure.error}");
          return Left(Failure(error: failure.error));
        },
        (accessToken) async {
          final eitherId = await userSharedPrefs.getAcessToken();
          return eitherId.fold(
            (failure) {
              // Handle failure to retrieve user ID
              print("Failed to retrieve user ID: ${failure.error}");
              return Left(Failure(error: failure.error));
            },
            (userId) async {
              print("access token $userId");
              var response = await dio.post(
                ApiEndpoints.listPlaylist,
                data: {"description": prompt, "access_token": accessToken},
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                  },
                ),
              );
              if (response.data.containsKey('playlist_id')) {
                return const Right(true);
              } else {
                return Left(Failure(
                    error: "Failed to load playlist",
                    statusCode: response.statusCode.toString()));
              }
            },
          );
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(Failure(
            error: 'API connection error',
            statusCode: e.response!.statusCode.toString()));
      } else {
        print(e);
        return Left(Failure(error: "API connection error", statusCode: "400"));
      }
    }
  }

  // Future<void> refreshToken() async {
  //   String? access;
  //   try {
  //     String? refresh;
  //     final eitherRefreshToken = await userSharedPrefs.getRefreshToken();
  //     eitherRefreshToken.fold(
  //       (failure) {
  //         // SnackBarManager.showSnackBar(
  //         //     isError: true, message: "Token Invalid", context: context);
  //       },
  //       (refrershToken) {
  //         // Handle success
  //         print("Token: $refrershToken");
  //         refresh = refrershToken;
  //         return refrershToken;
  //       },
  //     );
  //     if (refresh == null) {
  //       throw Exception('Refresh token not found.');
  //     }

  //     // Send request to refresh token
  //     Response response = await dio.post(
  //       'https://accounts.spotify.com/api/token',
  //       data: {
  //         'grant_type': "refresh_token",
  //         'refresh_token': refresh,
  //         'client_id': client_id,
  //       },
  //       options: Options(
  //         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       // Extract the new access token and expiration time from the response
  //       dynamic responseData = response.data;
  //       String newAccessToken = responseData['access_token'];
  //       int expiresIn = responseData['expires_in'];
  //       DateTime expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
  //       String newRefreshToken = responseData['refresh_token'];

  //       await userSharedPrefs.setAcessToken(newAccessToken);
  //       await userSharedPrefs.setRefreshToken(newRefreshToken);
  //       await userSharedPrefs.setExpiryDate(expiryTime);
  //     } else {
  //       throw Exception(
  //           'Failed to refresh token. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to refresh token: $e');
  //   }
  // }

  // var logger = Logger();

  // Future<String> getUserId() async {
  //   String? access;

  //   try {
  //     final eitherToken = await userSharedPrefs.getAcessToken();
  //     eitherToken.fold(
  //       (failure) {
  //         // SnackBarManager.showSnackBar(
  //         //     isError: true, message: "Token Invalid", context: context);
  //       },
  //       (accessToken) {
  //         // Handle success
  //         logger.d("Token: $accessToken");
  //         access = accessToken;
  //       },
  //     );
  //     if (access == null) {
  //       throw Exception('Access token not found.');
  //     }

  //     Response response = await dio.get(
  //       'https://api.spotify.com/v1/me',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $access',
  //         },
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       print(response);
  //       // Access the response body
  //       String responseBody = response.data;

  //       // Parse the JSON response
  //       Map<String, dynamic> jsonResponse = json.decode(responseBody);
  //       // Ensure 'id' key exists in the response data

  //       return jsonResponse['id'].toString(); // Ensure returning a String
  //     } else {
  //       print(response);
  //       throw Exception('Failed to load user info: ${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     // Handle Dio errors
  //     logger
  //         .e('Failed to load user info: DioException [${e.type}]: ${e.error}');
  //     throw Exception('Failed to load user info');
  //   } catch (e, stackTrace) {
  //     logger.e('Failed to load user info: $e $stackTrace');
  //     throw Exception('Failed to load user info');
  //   }
  // }

  // bool isTokenExpired(String? accessToken, DateTime? expiryTime) {
  //   if (accessToken == null || expiryTime == null) {
  //     // Token or expiry time is not available, consider it expired
  //     return true;
  //   }

  //   DateTime currentTime = DateTime.now();
  //   return currentTime.isAfter(expiryTime);
  // }

//   Future<void> createPlaylist() async {
//     try {
//       String? access;
//       DateTime? exp;

//       // Retrieve access token
//       final eitherToken = await userSharedPrefs.getAcessToken();
//       eitherToken.fold(
//         (failure) {
//           // Handle failure to retrieve access token
//           print("Failed to retrieve access token: ${failure.error}");
//         },
//         (accessToken) {
//           // Handle success
//           print("Access Token: $accessToken");
//           access = accessToken;
//         },
//       );

//       // Check if access token is available
//       if (access == null) {
//         throw Exception('Access token not found.');
//       }

//       // Retrieve expiration date
//       final eitherExpiryDate = await userSharedPrefs.getExpiryDate();
//       eitherExpiryDate.fold(
//         (failure) {
//           // Handle failure to retrieve expiration date
//           print("Failed to retrieve expiration date: ${failure.error}");
//         },
//         (expiryDate) {
//           // Handle success
//           print("Expiration Date: $expiryDate");
//           exp = expiryDate;
//         },
//       );

//       // Proceed with further logic using access token and expiration date
//       // For example, you can check if the access token is expired here
//       if (isTokenExpired(access, exp)) {
//         print('Access token is expired. Refreshing token...');
//         await RemoteService(); // Refresh the token
//         // Retrieve the new access token and expiry date
//         // Refresh access token and expiration date
//         final refreshedAccessToken = await userSharedPrefs.getAcessToken();
//         final refreshedExpiryDate = await userSharedPrefs.getExpiryDate();

//         // Handle success or failure of refreshing
//         refreshedAccessToken.fold(
//           (failure) {
//             // Handle failure
//             print("Failed to refresh access token: ${failure.error}");
//           },
//           (accessToken) {
//             // Handle success
//             print("Refreshed Access Token: $accessToken");
//           },
//         );

//         refreshedExpiryDate.fold(
//           (failure) {
//             // Handle failure
//             print("Failed to refresh expiration date: ${failure.error}");
//           },
//           (expiryDate) {
//             // Handle success
//             print("Refreshed Expiration Date: $expiryDate");
//             exp = expiryDate; // Update expiration date
//           },
//         );
//       }

//       String userId = "2f5pszulfs15eiosmaxdr31p0";
//       print("gpt uer $userId");
//       Response response = await dio.post(
//         'https://api.spotify.com/v1/users/$userId/playlists',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $access',
//             'Content-Type': 'application/json',
//           },
//         ),
//         data: jsonEncode({
//           'name': 'My Awesome Playlist',
//           'description': 'A playlist created with Flutter!',
//           'public': true, // Change to true if you want it to be public
//         }),
//       );

//       if (response.statusCode == 201) {
//         print('Playlist created successfully!');
//       } else {
//         print('Failed to create playlist. Status code: ${response.statusCode}');
//         print(response.data);
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
}
