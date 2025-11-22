import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int index;
  final bool showBackButton;

  NavigationState({this.index = 0, this.showBackButton = false});
  
  NavigationState copyWith({int? index, bool? showBackButton}) {
    return NavigationState(
      index: index ?? this.index,
      showBackButton: showBackButton ?? this.showBackButton,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return NavigationState();
  }

  void setIndex(int index) {
    state = state.copyWith(index: index, showBackButton: false);
  }

  void navigateTo(int index, {bool showBackButton = false}) {
    state = state.copyWith(index: index, showBackButton: showBackButton);
  }
  
  void goBack() {
    state = state.copyWith(index: 0, showBackButton: false);
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(NavigationNotifier.new);
