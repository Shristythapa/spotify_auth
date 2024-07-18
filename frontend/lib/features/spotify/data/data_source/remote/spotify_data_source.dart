import 'package:clean_spotify_connec/config/constants/api_endpoints.dart';
import 'package:clean_spotify_connec/core/error/failure.dart';
import 'package:clean_spotify_connec/core/shared_pref/user_shared_prefs.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SpotifyDataSource {
  final UserSharedPrefs userSharedPrefs;
  final Dio dio;

  SpotifyDataSource({required this.dio, required this.userSharedPrefs});

  Future<Either<Failure, bool>> authorizeUser() async {
    final Dio dio = Dio();

    try {
      Response response = await dio.get(ApiEndpoints.login);

      // Decode the response data to check for an error field
      if (response.data is Map<String, dynamic>) {
        Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey('error')) {
          // Handle the error field
          return Left(Failure(error: responseData['error']));
        } else {
          userSharedPrefs.setAcessToken(responseData['access_toke']);
          userSharedPrefs.setExpiryDate(responseData['expires_in']);
          return const Right(true);
        }
      } else {
        return Left(Failure(error: 'Invalid response format'));
      }
    } on DioException catch (e) {
      // Handle Dio errors separately
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        Map<String, dynamic> responseData = e.response!.data;

        if (responseData.containsKey('error')) {
          return Left(Failure(error: responseData['error']));
        }
      }
      return Left(Failure(error: e.message!));
    } catch (e) {
      // Handle any other type of error
      return Left(Failure(error: e.toString()));
    }
  }
}


//link to the refrence code
//https://medium.com/@ssk_karna/spotify-api-in-flutter-ed8ebc8eba03
  // Future<void> RemoteService() async {
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
  //         clientSecret: client_secret);
  //     print(accessToken);

  //     // Save access token, refresh token, and expiry date
  //     await userSharedPrefs.setAcessToken(accessToken.accessToken!);
  //     await userSharedPrefs.setRefreshToken(accessToken.refreshToken!);
  //     await userSharedPrefs.setExpiryDate(accessToken.expirationDate!);

  //     // Global variables
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

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
