import 'package:bykefastgo/presentation/providers/auth/auth_provider.dart';
import 'package:bykefastgo/shared/util/util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;
  final Password password;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
    Password? password,
  }) {
    return LoginFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return '''
      isPosting: $isPosting,
      isFormPosted: $isFormPosted,
      isValid: $isValid,
      email: $email,
      password: $password,
    ''';
  }
}

//! 2 - Como implementamos un notifier provider

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Function(String, String) loginUserCallback;

  LoginFormNotifier({
    required this.loginUserCallback,
  }) : super(LoginFormState());

  onEmailChange(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
        email: newEmail, isValid: Formz.validate([newEmail, state.password]));
  }

  onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    //notifica cambios en el state, notifica a todos los listeners
    state = state.copyWith(
        password: newPassword,
        isValid: Formz.validate([newPassword, state.email]));
  }

  Future<void> onFormSubmit() async {
    _touchEveryField();
    if (!state.isValid) return;
    state = state.copyWith(isPosting: true);
    try {
      await loginUserCallback(state.email.value, state.password.value);
    } catch (e) {
      print("Error durante la autenticación: $e");
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }

  _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    state = state.copyWith(
        isFormPosted: true,
        email: email,
        password: password,
        isValid: Formz.validate([email, password]));
  }
}

//! 3 - StateNotifierProvider - Consume afuera

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  final loginUserCallback = ref.watch(authProvider.notifier).loginUser;
  return LoginFormNotifier(loginUserCallback: loginUserCallback);
});
