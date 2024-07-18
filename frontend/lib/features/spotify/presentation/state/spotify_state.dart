class SpotifyState {
  final bool isLoading;
  final bool showMessage;
  final String? error;

  const SpotifyState({required this.isLoading, this.error, required this.showMessage});

  factory SpotifyState.initial() {
    return const SpotifyState(isLoading: false, error: "", showMessage: false);
  }

  SpotifyState copyWith({bool? isLoding, String? error, bool? showMessage }) {
    return SpotifyState(isLoading: isLoading, 
    error: error,
    showMessage:  showMessage?? this.showMessage);
  }
}
