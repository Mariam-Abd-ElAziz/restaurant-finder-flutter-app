import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc {
  final AuthService _authService = AuthService();


  // CONTROLLERS
  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _confirmPasswordController = BehaviorSubject<String>();

  final _loadingController = BehaviorSubject<bool>.seeded(false);
  final _errorController = BehaviorSubject<String?>();
  

  // STREAMS
  Stream<String> get nameStream =>
      _nameController.stream.transform(_validateName);

  Stream<String> get emailStream =>
      _emailController.stream.transform(_validateEmail);

  Stream<String> get passwordStream =>
      _passwordController.stream.transform(_validatePassword);
    
  Stream<String> get loginPasswordStream =>
    _passwordController.stream.transform(_validateLoginPassword);

  Stream<String> get confirmPasswordStream =>
      _confirmPasswordController.stream.transform(_validateConfirmPassword);

  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  String? get currentError => _errorController.valueOrNull;
  // INPUT FUNCTIONS
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeConfirmPassword =>
      _confirmPasswordController.sink.add;

  // VALIDATION
  final _validateName =
      StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      if (name.trim().isNotEmpty) {
        sink.add(name);
      } else {
        sink.addError("Name is required");
      }
    },
  );

  final _validateEmail =
      StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (email.contains('@')) {
        sink.add(email);
      } else {
        sink.addError("Invalid email");
      }
    },
  );

  final _validatePassword =
      StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length >= 8) {
        sink.add(password);
      } else {
        sink.addError("Password must be at least 8 characters");
      }
    },
  );

 final _validateLoginPassword =
    StreamTransformer<String, String>.fromHandlers(
  handleData: (password, sink) {
    if (password.isNotEmpty) {
      sink.add(password);
    } else {
      sink.addError("Password is required");
    }
  },
);

  StreamTransformer<String, String> get _validateConfirmPassword =>
      StreamTransformer<String, String>.fromHandlers(
        handleData: (confirmPassword, sink) {
          final password = _passwordController.valueOrNull;

          if (password != confirmPassword) {
            sink.addError("Passwords do not match");
          } else {
            sink.add(confirmPassword);
          }
        },
      );

  // FORM VALIDATION
  Stream<bool> get isSignupValid => Rx.combineLatest4(
        nameStream,
        emailStream,
        passwordStream,
        confirmPasswordStream,
        (a, b, c, d) => true,
      );

  Stream<bool> get isLoginValid => Rx.combineLatest2(
        emailStream,
        loginPasswordStream,
        (a, b) => true,
      );

  // SIGNUP (FIREBASE)
  Future<void> submitSignup() async {
  try {
    _loadingController.add(true);
    _errorController.add(null);

    final email = _emailController.valueOrNull ?? '';
    final password = _passwordController.valueOrNull ?? '';

    await _authService.signUp(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      _errorController.add('Email already exists');
    } else if (e.code == 'invalid-email') {
      _errorController.add('Invalid email format');
    } else if (e.code == 'weak-password') {
      _errorController.add('Password is too weak');
    } else {
      _errorController.add('Signup failed');
    }
  } catch (e) {
    _errorController.add('Something went wrong');
  } finally {
    _loadingController.add(false);
  }
}



  // LOGIN (FIREBASE)
 Future<void> submitLogin() async {
  try {
    _loadingController.add(true);
    _errorController.add(null);

    final email = _emailController.valueOrNull ?? '';
    final password = _passwordController.valueOrNull ?? '';

    await _authService.login(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found' ||
        e.code == 'wrong-password' ||
        e.code == 'invalid-email') {
      _errorController.add('Invalid email or password');
    } else {
      _errorController.add('Login failed. Please try again');
    }
  } catch (e) {
    _errorController.add('Something went wrong');

  } finally {
    _loadingController.add(false);
  }
}
  // DISPOSE
  void dispose() {
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _confirmPasswordController.close();
    _loadingController.close();
    _errorController.close();
  }
}