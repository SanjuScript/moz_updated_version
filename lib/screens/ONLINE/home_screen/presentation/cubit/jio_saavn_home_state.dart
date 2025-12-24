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
  final String languageKey;

  const JioSaavnHomeSuccess(this.data, {required this.languageKey});

  @override
  List<Object?> get props => [data];
}

class JioSaavnHomeError extends JioSaavnHomeState {
  final String message;

  const JioSaavnHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
