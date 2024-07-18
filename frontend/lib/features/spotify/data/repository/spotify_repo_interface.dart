import 'package:clean_spotify_connec/core/failure/failure.dart';
import 'package:clean_spotify_connec/features/spotify/domain/repository/spotify_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//is wifi available logic is written here with if statement

final spotifyRepositoryProvider =
    Provider.autoDispose<ISpotifyRepository>((ref) {
  //internet chaena bhaanai rocal repo use.
  return ref.read(spotifyRemoteRepositoryProvider);
});

abstract class ISpotifyRepository {
  Future<void> spotifyLogin();
  Future<Either<Failure, bool>> postPrompt(String prompt);
}
