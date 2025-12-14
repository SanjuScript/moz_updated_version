part of 'jio_saavn_home_cubit.dart';

abstract class JioSaavnHomeState extends Equatable {
  const JioSaavnHomeState();

  @override
  List<Object?> get props => [];
}

class JioSaavnHomeInitial extends JioSaavnHomeState {}

class JioSaavnHomeLoading extends JioSaavnHomeState {}

class JioSaavnHomeSuccess extends JioSaavnHomeState {
  final JioSaavnHomeResponse data;

  const JioSaavnHomeSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class JioSaavnHomeError extends JioSaavnHomeState {
  final String message;

  const JioSaavnHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
