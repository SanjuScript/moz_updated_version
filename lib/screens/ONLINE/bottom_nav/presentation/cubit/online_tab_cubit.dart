import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'online_tab_state.dart';

class OnlineTabCubit extends Cubit<OnlineTabState> {
  OnlineTabCubit() : super(const OnlineTabState(0));

  void changeTab(int index) {
    emit(OnlineTabState(index));
  }
}
