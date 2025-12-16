import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<bool> {
  AuthCubit() : super(sl<UserStorageAbRepo>().isLoggedIn());

  Future<void> refresh() async {
    emit(sl<UserStorageAbRepo>().isLoggedIn());
  }
}
