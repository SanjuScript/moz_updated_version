part of 'auto_complete_cubit.dart';

abstract class AutocompleteState extends Equatable {
  const AutocompleteState();
  @override
  List<Object?> get props => [];
}

class AutocompleteInitial extends AutocompleteState {}

class AutocompleteLoading extends AutocompleteState {}

class AutocompleteSuccess extends AutocompleteState {
  final List<String> suggestions;
  const AutocompleteSuccess(this.suggestions);
  @override
  List<Object?> get props => [suggestions];
}

class AutocompleteError extends AutocompleteState {
  final String message;
  const AutocompleteError(this.message);
  @override
  List<Object?> get props => [message];
}
