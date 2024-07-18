// import 'package:clean_spotify_connec/core/shared_pref/user_shared_prefs.dart';
// import 'package:clean_spotify_connec/features/spotify/data/data_source/spotify_remote_data_source.dart';
// import 'package:clean_spotify_connec/features/spotify/presentation/state/spotify_state.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final sharedPrefViewModelProvider =
//     SharedPrefViewModel<SharedPrefViewModel>((ref) {
//   final photoDataSource = ref.read(spotifyRemoteDatasourceProvider);
//   final UserSharedPrefs = ref.read(userSharedPrefsProvider);
//   return SharedPrefViewModel(photoDataSource, UserSharedPrefs);
// });

// class SharedPrefViewModel extends StateNotifier<SpotifyState> {
//   final SpotifyRemoteDataSource _spotifyRemoteDataSource;
//   final UserSharedPrefs userSharedPrefs;

//   SharedPrefViewModel(this._spotifyRemoteDataSource, this.userSharedPrefs)
//       : super(SpotifyState.initial());

//   Future resetState() async {
//     state = SpotifyState.initial();
//   }

//   Future login() async {
//     state = state.copyWith(isLoding: true);

//     await _spotifyRemoteDataSource.RemoteService();

//     // result.fold((failure) => state.copyWith(isLoding: false),
//     //     (data) => state.copyWith(isLoding: false));
//   }

//   void sendPrompt(String prompt) {
//     state = state.copyWith(isLoding: true);
//     _spotifyRemoteDataSource.postPrompt(prompt).then((value) {
//       value.fold(
//           (failure) => state = state.copyWith(
//               isLoding: true, error: failure.error, showMessage: true),
//           (success) => state = state.copyWith(
//                 isLoding: false,
//                 showMessage: true,
//               ));
//     });
//   }

//   Future<String?> getAccessToken() async {
//     final eitherToken = await userSharedPrefs.getAcessToken();
//     eitherToken.fold(
//       (failure) {
//         // SnackBarManager.showSnackBar(
//         //     isError: true, message: "Token Invalid", context: context);
//       },
//       (acess_token) {
//         // Handle success
//         print("Token: $acess_token");
//         return acess_token;
//       },
//     );
//   }

//   Future<String?> getRefreshToken() async {
//     final eitherToken = await userSharedPrefs.getRefreshToken();
//     eitherToken.fold(
//       (failure) {
//         // SnackBarManager.showSnackBar(
//         //     isError: true, message: "Token Invalid", context: context);
//       },
//       (refresh_token) {
//         // Handle success

//         print("Token: $refresh_token");
//         return refresh_token;
//       },
//     );
//   }
// }
